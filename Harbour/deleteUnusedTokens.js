// remove service tokens which cant be found in mongo. 
var tokens = require('../mongodb/getContainerId.js');
var redis = require('redis').createClient("6379", "localhost");
var mongoHost = 'mongodb://10.0.1.34:27017/runnable2';
var mongoServicesTokens = [];

tokens.getServicesToken(mongoHost, gotServicesToken);

function gotServicesToken(err, servicesTokens) {
  if (err) {
    console.dir(err);
    return;
  }
  console.log("got servicesTokens from mongodb. num: "+servicesTokens.length);
  mongoServicesTokens = servicesTokens;
  redis.keys("harbourmasterSession:*", gotKeys);
}

function gotKeys(err, keys) {
  if(err) {
    console.dir(err);
    return;
  }
  console.log("got keys from redis. num: "+keys.length);
  var numToRemove = keys.length - mongoServicesTokens.length;
  if (numToRemove <= 0) {
    console.error("more keys in mongo then redis");
    return;
  }
  console.log("we need to remove "+numToRemove);
  var multi = redis.multi();
  var numRemoving = 0;
  keys.forEach(function (key, i) {
    token = key.slice(21,-1);
    if (mongoServicesTokens.indexOf(token) <= -1) {
        console.log("deleting: "+key);
        numRemoving++;
        multi.del(key);
    }
  });
  if (numToRemove !== numRemoving) {
    console.error("removing wrong number. removing: "+numRemoving+" should be removing: "+numToRemove);
    return;
  }
  multi.exec(function (err, replies) {
    if(err) {
      console.dir(err);
      return;
    }
    console.log("finshed. num replies: "+replies.length);
    redis.quit();
  });
}
