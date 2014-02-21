var MongoClient = require('mongodb').MongoClient;
var ObjectID = require('mongodb').ObjectID;
var items = require('./migration.json');
var async = require('async');
var request = require('request');

MongoClient.connect('mongodb://127.0.0.1:27017/runnable', function (err, db) {
  if (err) {
    throw err;
  }
  var images = db.collection('images');
  async.each(items, function (item, cb) {
    request({
      url: 'http://runnable.com/api/projects/' + item.id,
      json: {}
    }, function (err, res, data) {
      if (err) {
        return cb(err);
      }
      var image = {
        _id: ObjectID(data.id),
        name: item.name,
        owner: ObjectID(data.owner),
        parent: data.parent ? ObjectID(base64ToHex(data.parent)) : null,
        created: data.created,
        cmd: 'date',
        port: '80',
        synced: false,
        tags: [],
        file_root: item.framework == 'web' ? '/var/www' : '/var/www/app',
        files: []
      };
      item.tags.forEach(function (tag) {
        image.tags.push({
          _id: ObjectID(),
          name: tag
        });
      });
      data.defaultFile.forEach(function (file) {
        var parts = file.split('/');
        var name = parts.pop();
        var path = '/' + parts.join('/');
        image.files.push({
          _id: ObjectID(),
          name: name,
          path: path,
          dir: false,
          default: true,
          ignore: false
        });
      });      
      console.log(image);
      images.insert(image, cb);
    });
  }, function (err) {
    if (err) {
      throw err;
    }
    console.log('woot');
  });
});

function base64ToHex (base64) {
  var minus = /-/g;
  var underscore = /_/g;
  return (new Buffer(base64.toString().replace(minus,'+').replace(underscore,'/'), 'base64')).toString('hex');
};
