// PULL IMAGES FROM DB
var mongo = require('mongoskin');
var hex64 = require('hex64');
var async = require('async');
var Docker = require('dockerode');
var docker = new Docker({
    host: "http://localhost",
    port: 4242
  });
var fs = require('fs');
var path = require('path');
var limit = 1500;
function pullTopImagesFromDb () {
  var db = mongo.db("mongodb://10.0.1.47:27017/runnable2", {native_parser:true});
  db.bind('images');
  db.images.find({}, { _id: 1, revisions:1 })
    .sort({ views: -1 })
    .limit(limit)
    .toArray(mapAndCreateFile)
    .close();
}
function mapAndCreateFile (err, images) {
  if (err) throw err;

  var imageUrls = images.map(function (image) {
    var repoName;
    if (image.revisions && image.revisions.length) {
      var revision = image.revisions[image.revisions.length-1];
      var repoId = (revision.repo || revision._id).toString();
      repoName = repoId
    } else {
      repoName = image._id.toString();
    }

    return 'registry.runnable.com/runnable/'+repoName;
  });
  var filename = 'top'+limit+'Images'+Date.now()+'.js';
  console.log("writing to file" + filename);
  fs.writeFileSync(path.join(__dirname, filename), 'module.exports='+JSON.stringify(imageUrls));
  console.log("done ctrl^c to close");
}
console.log("start");
pullTopImagesFromDb();
