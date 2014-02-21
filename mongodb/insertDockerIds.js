var plus = /\+/g;
var slash = /\//g;
var minus = /-/g;
var underscore = /_/g;

function decode (id) {
  return (new Buffer(
    id
     .toString()
     .replace(minus,'+')
     .replace(underscore,'/'), 
    'base64')
  ).toString('hex');
}

var MongoClient = require('mongodb').MongoClient;

MongoClient.connect('mongodb://127.0.0.1:27017/runnable', function (err, db) {
  if (err) {
    throw err;
  }
  var images = db.collection('images');
  require('fs').readFileSync('./pairs.txt').toString().split('\n')
    .forEach(function (pair) {
      if (!pair) {
        return false;
      }
      var split = pair.split(' ');
      var id = decode(split[0]);
      var dockerId = split[1];
      console.log({
        id: id,
        dockerId: dockerId
      });
      if (id.length != 16) { return false } 
      images.findAndModify({ _id: new require('mongodb').ObjectID(id)}, [['_id', 'asc']], {$set: {docker_id: dockerId}}, {}, function (err, image) {
        //console.log(err, image, dockerId);
        if (err || !image) {
          return false; //throw new Error(err);
        }
        //image.docker_id = dockerId;
        console.log(image);
        //image.save();
      });
    });
});
