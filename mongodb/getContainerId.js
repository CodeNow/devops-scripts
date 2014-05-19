var MongoClient = require('mongodb').MongoClient;

module.exports = function(cb) { 
  MongoClient.connect('mongodb://10.0.1.47:27017/runnable2', function(err, db) {
    if(err) {
      console.error("err"+err);
      cb(err);
      return;
    }
    var collection = db.collection('containers');
    // Locate all the entries using find
    collection.find({},{_id:0,containerId:1}).toArray(function(err, results) {
      // console.dir(results);
      // Let's close the db
      db.close();
      cb(err, results);
    });
  });
};