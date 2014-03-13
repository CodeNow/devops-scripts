// PULL IMAGES FROM DB
var mongo = require('mongoskin');
var hex64 = require('hex64');
var async = require('async');
var Docker = require('dockerode');
var docker = new Docker({socketPath: '/var/run/docker.sock'});
var fs = require('fs');
var path = require('path');
var limit = 2000;
function pullTopImagesFromDb () {
  var db = mongo.db("mongodb://localhost:27017/runnable2", {native_parser:true});
  db.bind('images');
  db.images.find({}, { _id: 1, revisions:1 })
    .sort({ views: -1 })
    .limit(limit)
    .toArray(mapAndCreateFile);
}
function mapAndCreateFile (err, images) {
  if (err) throw err;

  var imageUrls = images.map(function (image) {
    var imageId64;
    if (image.revisions && image.revisions.length) {
      var revision = image.revisions[image.revisions.length-1];
      var repoId = (revision.repo || revision._id).toString();
      imageId64 = hex64.transform(repoId);
    }
    else {
      imageId64 = hex64.transform(image._id.toString());
    }

    return 'registry.runnable.com/runnable/'+imageId64;
  });

  var filename = 'top'+limit+'Images'+Date.now()+'.js';
  fs.writeFileSync(path.join(__dirname, filename), 'module.exports='+JSON.stringify(imageUrls));
}
pullTopImagesFromDb();
