// MUST BE RUN FROM HARBOURMASTER !!!
// MUST BE RUN FROM HARBOURMASTER !!!
// MUST BE RUN FROM HARBOURMASTER !!!

var async = require('async');
var hex64 = require('hex64');
var sessRedisInfo = {
  "ipaddress": "127.0.0.1", // harbourmaster!!
  "port": "6379"
};
var domain, redisInfo, mongo;
if (process.env.NODE_ENV === 'integration') {
  domain = 'cloudcosmos.com';
  redisInfo = {
    "ipaddress": "10.0.1.14",
    "port": "6379"
  };
  mongo = '10.0.1.176';
}
if (process.env.NODE_ENV === 'staging') {
  domain = 'runnable.pw';
  redisInfo = {
    "ipaddress": "10.0.1.125",
    "port": "6379"
  };
  mongo = '10.0.1.34';
}
if (process.env.NODE_ENV === 'production') {
  domain = 'runnable.com';
  redisInfo = {
    "ipaddress": "10.0.1.20",
    "port": "6379"
  };
  mongo = '10.0.1.47';
}

// DATABASES
var db = require('mongojs')(mongo+':27017/runnable2');
var containers = db.collection('containers');
var sessRedis = require('redis').createClient(sessRedisInfo.port, sessRedisInfo.ipaddress);
var redis = require('redis').createClient(redisInfo.port, redisInfo.ipaddress);
console.log('sessions redis');


async.waterfall([
  containers.find.bind(containers, {}, {servicesToken:1}),
  setEachHostAndContainerInfo
], done);


function setEachHostAndContainerInfo (containers, cb) {
  async.eachLimit(containers, 1, setHostAndContainerInfo, cb);
}

function setHostAndContainerInfo (container, cb) {
  async.waterfall([
    getSessionAndPorts(container),
    updateContainer,
    updateFrontdoorStartUrl(container)
  ], cb);

  function updateContainer (data, cb) {
    if (!data.ports) {
      cb(new Error(container._id+' missing ports'));
    }
    else if (!data.session) {
      cb(new Error(container._id+' missing session'));
    }
    else if (!data.session.docklet) {
      cb(new Error(container._id+' missing dockIp'));
    }
    else if (!data.session.containerId) {
      cb(new Error(container._id+' missing containerId'));
    }
    else {
      // parse ports string to json!
      try {
        data.ports = JSON.parse(data.ports);
      }
      catch (err) {
        return cb(err);
      }
      // update mongo
      var session = data.session;
      var ports = data.ports;
      var $set = {
        host: session.docklet,
        containerId: session.containerId,
        webPort: ports.webPort,
        servicesPort: ports.servicesPort
      };
      data.container = container;
      containers.update({ _id: container._id }, {
        $set: $set
      }, function (err, numDocs) {
        cb(err, data); // pass through data
      });
    }
  }
}

function updateFrontdoorStartUrl (container) {
  var servicesToken = container.servicesToken;
  var hipacheKey = getHipacheKey(container);
  return function (data, cb) {
    data.ports.startUrl = containerStartUrl(container);
    // cb();
    redis.lset(hipacheKey, 0, JSON.stringify(data.ports), cb);
  };
}

function getSessionAndPorts (container) {
  var servicesToken = container.servicesToken;
  var sessionKey = getSessionKey(container);
  var hipacheKey = getHipacheKey(container);
  return function (cb) {
    async.parallel({
      session: sessRedis.hgetall.bind(sessRedis, sessionKey),
      ports  : redis.lindex.bind(redis, hipacheKey, 0)
    }, cb);
  };
}

function done (err) {
  if (err) {
    throw err;
  }
  else {
    console.log('DONE!');
    process.exit();
  }
}




function getSessionKey (container) {
  return 'harbourmasterSession:'+container.servicesToken;
}
function getHipacheKey (container) {
  return 'frontend:'+container.servicesToken+'.'+domain;
}
function containerStartUrl (container) {
  return [
    'http://api.', domain,
    '/users/me/runnables/', encodeId(container._id), '/start',
    '?servicesToken=', container.servicesToken
  ].join('');
}
var plus = /\+/g;
var slash = /\//g;
var minus = /-/g;
var underscore = /_/g;
function encodeId (id) {
  return new Buffer(id.toString(), 'hex')
    .toString('base64')
    .replace(plus, '-')
    .replace(slash, '_');
}