// remove service tokens which cant be found in mongo. 
var tokens = require('../mongodb/getContainerId.js');
var redis = require('redis').createClient("6379", "localhost");
var mongoHost = 'mongodb://10.0.1.47:27017/runnable2';
var mongoServicesTokens = [];

tokens.getServicesToken(mongoHost, gotServicesToken);

function gotServicesToken(err, servicesTokens) {
  if (err) {
    console.dir(err);
    return;
  }
  mongoServicesTokens = servicesTokens;
  redis.keys("harbourmasterSession:*", gotKeys);
}

function gotKeys(err, keys) {
  if(err) {
    console.dir(err);
    return;
  }
  keys.forEach(function (key, i) {
    if (mongoServicesTokens.indexOf(key) <= -1) {
        redis.del(key);
    }
  });
  redis.quit();
}
