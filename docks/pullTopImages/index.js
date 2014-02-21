var mongo = require('mongoskin');
var hex64 = require('hex64');
var async = require('async');
var exec = require('child_process').spawn;

function log (data) {
  console.log(data.toString());
}

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
  pullImageUrls(require('./imageUrls'));
}

function pullImageUrls (imageUrls) {
  async.eachSeries(imageUrls, dockerPull, done);
    function dockerPull (url, cb) {
      var pullCmd = 'sudo docker pull '+url;
      console.log('<<< '+pullCmd+' >>>');
      var dockerPull = spawn(pullCmd);
      dockerPull.stdout.on('data', log);
      dockerPull.stderr.on('data', log);
      dockerPull.on('close', function (code) {
        if (code !== 0) {
          cb(new Error('docker pull fail code: '+code))
        }
        else {
          console.log('....SUCCESS');
          cb();
        }
      });
    }
    function done (err) {
      if (err) throw err;
      console.log('....DONE!!!!');
    }
}