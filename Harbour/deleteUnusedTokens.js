// remove service tokens which cant be found in mongo. 
var tokens = require('../mongodb/getContainerId.js');
var redis = require('redis').createClient("6379", "localhost");
var mongoHost = 'mongodb://10.0.1.176:27017/runnable2';
var mongoServicesTokens = [];

tokens.getServicesToken(mongoHost, gotServicesToken);

function gotServicesToken(err, servicesTokens) {
  if (err) {
    console.dir(err);
    return;
  }
  console.log("got servicesTokens from mongodb");
  mongoServicesTokens = servicesTokens;
  redis.keys("harbourmasterSession:*", gotKeys);
}

function gotKeys(err, keys) {
  if(err) {
    console.dir(err);
    return;
  }
  console.log("got keys from redis");
  var multi = redis.multi();
  keys.forEach(function (key, i) {
    if (mongoServicesTokens.indexOf(key) <= -1) {
        console.log("deleting: "+key);
        multi.del(key);
    }
  });
  multi.end(function (err) {
    redis.quit();
  });
}
