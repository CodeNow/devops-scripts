// remove orphen containers
var tokens = require('../mongodb/getContainerId.js');
var redis = require('redis').createClient("6379", "10.0.1.14");

function gotSession (err, data) {
  if (err) {
    console.error("error: " +err);
  } else if (data === null) {
    console.error('Session not found' + err);
  } else {
    console.dir(data);      
  }
}

for (var i = 0; i < tokens.length; i++) {
  console.log("getting "+tokens[i]);
  redis.hgetall('harbourmasterSession:' + tokens[i], gotSession);
}