// remove orphen containers
var tokens = require('../mongodb/getContainerId.js');
var redis = require('redis').createClient("6379", "10.0.1.14");

function gotSession (err, data) {
  if (err) {
    next(err);
  } else if (data === null) {
    err = new Error('Session not found');
    err.code = 404;
    reportError('Session not found', err, req);
  } else {
    console.dir(data);      
  }
}

for (var i = 0; i < tokens.length; i++) {
  redis.hgetall('harbourmasterSession:' + tokens[i], gotSession);
}