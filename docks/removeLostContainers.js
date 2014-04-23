// remove orphen containers
var tokens = require('../mongodb/getContainerId.js');
var redis = require('redis').createClient("6379", "10.0.1.243");
tokens.getServicetokens(gotTokens);

function gotTokens(err, tokens) {
  for (var i = 0; i < tokens.length; i++) {
    redis.hgetall('harbourmasterSession:' + tokens[i].servicesToken, gotSession);
  }
}

function gotSession (err, data) {
  if (err) {
    // console.error("error: " +err);
  } else if (data === null) {
    // console.error('error: Session not found ' + err);
  } else {
    console.log(data.containerId);
  }
}