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
    console.log('1', image.files);
    var files = image.files.map(function (file) {
        file.path = file.path.replace(file.name, '');
        return file;
    });
    console.log('2', files);
    images.findAndModify({
      _id: image._id
    }, 
    [['_id', 'asc']], 
    {
      $set: {
        files: files
      }
    }, 
    {}, 
    function (err, image) {
      if (err) {
        throw err;
      }
      console.log('3', image);
    });
  });
});
