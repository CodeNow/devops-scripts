var MongoClient = require('mongodb').MongoClient;

MongoClient.connect('mongodb://10.0.1.176:27017/runnable2', function(err, db) {
  if(err) throw err;
  console.log("connected");
  var collection = db.collection('containers');

  // Locate all the entries using find
  collection.find({},{_id:0,servicesToken:1}).toArray(function(err, results) {
    console.dir(results);
    // Let's close the db
    db.close();
  });
});