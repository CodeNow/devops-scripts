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
    console.log('1', image);
    // if (typeof image.tags === 'string') {
    //   var tags = [{
    //     name: image.tags
    //   }];
    // } else {
    //   var tags = image.tags.map(function find (tag) {
    //     if (typeof tag === 'string') {
    //       return {
    //         name: tag
    //       };
    //     } else if (typeof tag.name === 'string') {
    //       return tag;
    //     } else {
    //       return find(tag.name);
    //     }
    //   });
    // }
    // console.log('2', tags);
    // images.findAndModify({
    //   _id: image._id
    // }, 
    // [['_id', 'asc']], 
    // {
    //   $set: {
    //     tags: tags
    //   }
    // }, 
    // {}, 
    // function (err, image) {
    //   if (err) {
    //     throw err;
    //   }
    //   console.log('3', image);
    // });
  });
});
