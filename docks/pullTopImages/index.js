var mongo = require('mongoskin');
var hex64 = require('hex64');
var async = require('async');
var Docker = require('dockerode');

var dockerHost = 'http://localhost';
var dockerPort = 4242;
var docker = new Docker({
    host: dockerHost,
    port: dockerPort
  });
function log (data) {
  console.log(data.toString());
}
function dockerCallback (cb) {
  return function (err, stream) {
    if (err) {
      throw err;
    } else {
      stream.on('data', dockerOnData);
      stream.on('error', dockerOnError);
      stream.on('end', cb);
    }
  };
  function dockerOnData (raw) {
    var data = JSON.parse(raw);
    if (data.error) {
      console.log('data err', data.error);
      // throw new Error('data err');
    }
  }
  function dockerOnError (err) {
    console.log('res err', err);
    // throw err;
  }
}

// PULL IMAGES FROM DB
// function pullTopImagesFromDb () {
//   var db = mongo.db("mongodb://localhost:27017/runnable2", {native_parser:true});
//   db.bind('images');
//   db.images.find({}, { _id: 1, revisions:1 })
//     .sort({ views: -1 })
//     .limit(300)
//     .toArray(pullImages);
// }
// function pullImages (err, images) {
//   if (err) throw err;

//   var imageUrls = images.map(function (image) {
//     var imageId64;
//     if (image.revisions && image.revisions.length) {
//       var revision = image.revisions[image.revisions.length-1];
//       var repoId = (revision.repo || revision._id).toString();
//       imageId64 = hex64.transform(repoId);
//     }
//     else {
//       imageId64 = hex64.transform(image._id.toString());
//     }

//     return 'registry.runnable.com/runnable/'+imageId64;
//   });

//   pullImageUrls(pullImageUrls);
// }

pullTopImagesFromFile();

function pullTopImagesFromFile () {
  pullImageUrls(require('./imageUrls').map(function (url) {
    var parts = url.split('/');
    var id = parts.pop();
    parts.push(hex64.decode(id));
    return parts.join('/');
  }));
}

function pullImageUrls (imageUrls) {
  async.eachSeries(imageUrls, dockerPullUrl, done);
    function dockerPullUrl (url, cb) {
      console.log('<<< '+url+' >>>');
      docker.pull(url, {
        registry: 'http://registry.runnable.com:5000'
      }, dockerCallback(cb));
    }
    function done (err) {
      if (err) throw err;
      console.log('....DONE!!!!');
    }
}
