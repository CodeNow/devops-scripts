var knox = require('knox');
var async = require('async');
var fs = require('fs');

var minus = /-/g;
var underscore = /_/g;

function decodeId (id) {
  return new Buffer(id
    .toString()
    .replace(minus, '+')
    .replace(underscore, '/'), 'base64')
    .toString('hex');
};

var client = knox.createClient({
    key: 'AKIAJA3VH6N377FCXOAQ'
  , secret: '1u3sPGgzIVJcDNI7uNYVmDzhiPRUQewnn9ke2+qL'
  , bucket: 'runnableimages'
});

async.waterfall([
  function (cb) {
    fs.readdir('/prod/repositories/runnable', cb);
  },
  function (folders, cb) {
    cb(null, folders.filter(function (name) {
      return name.length === 16;
    }));
  },
  function (folders, cb) {
    cb(null, folders.map(function (name) {
      return {
        name: name,
        decoded: decodeId(name)
      };
    }));
  },
  function (folders, cb) {
    async.map(folders, function (folder, cb) {
      fs.readFile('/prod/repositories/runnable/' +
        folder.name +
        '/_index_images', function (err, index) {
          if (err) {
            cb(err);
          } else {
            folder.index = index;
            cb(null, folder);
          }
        });
    }, cb);
  },
  function (folders, cb) {
    async.map(folders, function (folder, cb) {
      fs.readFile('/prod/repositories/runnable/' +
        folder.name +
        '/tag_latest', function (err, latest) {
          if (err) {
            console.error(err);
            JSON.parse(folder.index).forEach(function (entry) {
              if (entry.checksum) {
                folder.latest = entry.id;
              }
            });
            cb(null, folder);
          } else {
            folder.latest = latest;
            cb(null, folder);
          }
        });
    }, cb);
  }
], function (err, folders) {
  if (err) {
    throw err;
  }
  async.series([
    function (cb) {
      async.eachSeries(folders, function (folder, cb) {
        var req = client.put('/repositories/runnable/' +
          folder.decoded +
          '/_index_images', {
            'Content-Length': folder.index.length
          , 'Content-Type': 'application/json'
        });
        req.on('response', function (res) {
          if (200 == res.statusCode) {
            console.log('saved to %s', req.url);
            cb();
          } else {
            cb(new Error(res.body));
          }
        });
        req.end(folder.index);
      }, cb);
    },
    function (cb) {
      async.eachSeries(folders, function (folder, cb) {
        if (folder.latest) {
          var req = client.put('/repositories/runnable/' +
            folder.decoded +
            '/tag_latest', {
              'Content-Length': folder.latest.length
            , 'Content-Type': 'text/plain'
          });
          req.on('response', function (res) {
            if (200 == res.statusCode) {
              console.log('saved to %s', req.url);
              cb();
            } else {
              cb(new Error(res.body));
            }
          });
          req.end(folder.latest);
        } else {
          var req = client.del('/repositories/runnable/' +
            folder.decoded +
            '/tag_latest');
          req.on('response', function (res) {
            if (204 == res.statusCode) {
              console.log('deleted %s', req.url);
              cb();
            } else {
              console.log(res.statusCode, res.headers);
              cb(new Error(res.body));
            }
          });
          req.end();
          cb();
        }
      }, cb);
    }
  ], function (err) {
    if (err) {
      throw err;
    }
    console.log('DONE');
    process.exit();
  });
});