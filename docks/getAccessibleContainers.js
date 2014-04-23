// remove orphen containers
var tokens = require('../mongodb/getContainerId.js');
var redis = require('redis').createClient("6379", "localhost");
tokens.getServicetokens(gotTokens);

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