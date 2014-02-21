var MongoClient = require('mongodb').MongoClient;
var ObjectID = require('mongodb').ObjectID;

MongoClient.connect('mongodb://127.0.0.1:27017/runnable', function (err, db) {
  if (err) {
    throw err;
  }
  var images = db.collection('images');
  var first = true;
  images.find().each(function (err, image) {
    if (err) {
      throw err;
    }
    if (!image) {
      return false;
    }
    image.tags.forEach(function (tag) {
        tag._id = new ObjectID();
    });
    image.files.forEach(function (file) {
        file._id = new ObjectID();
    });

    images.update({
      _id: image._id
    },
    {
      $set: {
        tags : image.tags,
        files: image.files
      }
    },
    function (err, success) {
      if (err) {
        throw err;
      }
      else {
        console.log('success', success);
      }
    });
  });
});
