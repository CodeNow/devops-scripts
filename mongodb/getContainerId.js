var MongoClient = require('mongodb').MongoClient;

var getServicesToken = function(host, cb) { 
  MongoClient.connect(host, function(err, db) {
    if(err) {
      console.error("err"+err);
      cb(err);
      return;
    }
    var collection = db.collection('containers');
    // Locate all the entries using find
    collection.find({},{_id:0,servicesToken:1}).toArray(function(err, results) {
      // Let's close the db
      db.close();
      cb(err, results);
    });
  });
};

module.exports.getServicesToken = getServicesToken;
