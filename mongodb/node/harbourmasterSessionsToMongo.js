var async = require('async');
var domain;

var redisInfo;
if (process.env.NODE_ENV === 'integration') {
  domain = 'cloudcosmos.com';
  redisInfo = {
    "ipaddress": "10.0.1.191",
    "port": "6379"
  };
}
if (process.env.NODE_ENV === 'staging') {
  domain = 'runnable.pw';
  redisInfo = {
    "ipaddress": "10.0.1.9", // harbourmaster!!
    "port": "6379"
  };
}
if (process.env.NODE_ENV === 'production') {
  domain = 'runnable.com';
  redisInfo = {
    "ipaddress": "10.0.1.243", // harbourmaster!!
    "port": "6379"
  };
}

// DATABASES
var db = require('mongojs')('localhost:27017/runnable2');
var redis = require('redis').createClient(redisInfo.port, redisInfo.ipaddress);


async.waterfall([
  redis.keys.bind(redis, "harbourmasterSession:*"),
  getSessionAndPortsData,
  addSessionsToMongoDb
], done);

//// -- get old data
function getSessionAndPortsData (sessionKeys, cb) {
  async.map(sessionKeys, getSessionsAndPorts, cb);
}

function getSessionAndPorts (sessionKey, cb) {
  var servicesToken = key.replace('harbourmasterSession:', '');
  var hipacheKey = 'frontend:'+servicesToken+'.'+domain;
  async.parallel({
    session: redis.hgetall.bind(redis, sessionKey),
    ports  : redis.lrange.bind(redis, hipacheKey, 0, 0)
  }, cb);
}


//// -- put into mongo
function addDataToMongoDb (dataArr, cb) {
  async.eachLimit(dataArr, 1, updateContainer, cb);
}

function updateContainer (data, cb) {
  // parse ports data
  try {
    data.ports = JSON.parse(data.ports[0]);
  }
  catch (err) {
    return cb(err);
  }
  // validate
  var session = data.session;
  var ports = data.ports;
  if (!session.docklet) {
    cb(new Error('no docklet (host)??'));
  }
  else if (!ports.servicesPort) {
    cb(new Error('no servicesPort??'));
  }
  else if (!ports.webPort) {
    cb(new Error('no webPort??'));
  }
  else {
    var query = {
      servicesToken: session.servicesToken
    };
    var update = {
      $set: {
        host: session.docklet,
        servicesPort: ports.servicesPort,
        webPort: ports.webPort
      }
    };
    console.log(query, update);
    // db.containers.update(query, update, cb);
    cb();
  }
}


function done (err) {
  if (err) {
    throw err;
  }
  else {
    console.log('DONE!');
  }
}