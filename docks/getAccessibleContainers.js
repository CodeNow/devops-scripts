// remove orphen containers
var tokens = require('../mongodb/getContainerId.js');
var redis = require('redis').createClient("6379", "localhost");
var mongoHost = 'mongodb://10.0.1.47:27017/runnable2';
tokens.getServicesToken(mongoHost, gotTokens);

var count = 0;
var tcount = 0;
function gotTokens(err, tokens) {
  tcount = tokens.length;
  for (var i = 0; i < tokens.length; i++) {
    redis.hgetall('harbourmasterSession:' + tokens[i].servicesToken, gotSession);
  }
}

function gotSession (err, data) {
  count++;
  if (err) {
    // console.error("error: " +err);
  } else if (data === null) {
    // console.error('error: Session not found ' + err);
  } else {
    console.log(data.containerId);
  }
  if(count === tcount) {
    redis.quit();
  }
}