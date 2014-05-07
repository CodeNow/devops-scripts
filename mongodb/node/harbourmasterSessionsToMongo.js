// MUST BE RUN FROM HARBOURMASTER !!!
// MUST BE RUN FROM HARBOURMASTER !!!
// MUST BE RUN FROM HARBOURMASTER !!!

var async = require('async');
var hex64 = require('hex64');
var dryrun = process.env.DRYRUN;
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

if (dryrun) {
  console.log('DRYRUN!!');
  console.log('DRYRUN!!');
  console.log('DRYRUN!!');
}

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
    var err;
    if (!data) {
      cb(null, null); // skip
    }
    else if (!data.sessionPorts) {
      err = new Error(container._id+' missing session ports', container.servicesToken);
      err.deleteContainerAndContinue = true;
    }
    else if (!data.webPorts) {
      err = new Error(container._id+' missing web ports', container.webToken);
      err.deleteContainerAndContinue = true;
    }
    else if (!data.session) {
      err = new Error(container._id+' missing session', container.servicesToken);
      err.deleteContainerAndContinue = true;
    }
    else if (!data.session.docklet) {
      err = new Error(container._id+' missing dockIp', container.servicesToken);
    }
    else if (!data.session.containerId) {
      err = new Error(container._id+' missing containerId', container.servicesToken);
    }
    if (err) {
      if (err.deleteContainerAndContinue) {
        console.log('DELETE THIS CONTAINER', container._id, err.message);
        cb(null, null);
      }
      else {
        cb(err);
      }
    }
    else {
      // parse ports string to json!
      try {
        data.webPorts = JSON.parse(data.webPorts);
        data.sessionPorts = JSON.parse(data.sessionPorts);
      }
      catch (error) {
        return cb(error);
      }
      // update mongo
      var session = data.session;
      var ports = data.sessionPorts;
      var $set = {
        host: session.docklet,
        containerId: session.containerId,
        webPort: ports.webPort,
        servicesPort: ports.servicesPort
      };
      if (dryrun) {
        console.log('\n', container._id, $set, '\n');
        cb(null, data);
      }
      else {
        containers.update({ _id: container._id }, {
          $set: $set
        }, function (err, numDocs) {
          cb(err, data); // pass through data
        });
      }
    }
  }
}

function updateFrontdoorStartUrl (container) {
  var servicesToken = container.servicesToken;
  var hipacheSessionKey = getSessionHipacheKey(container);
  var hipacheWebKey = getWebHipacheKey(container);
  return function (data, cb) {
    if (!data || dryrun) { return cb(); }
    data.sessionPorts.startUrl = containerStartUrl(container);
    data.webPorts.startUrl = containerStartUrl(container);
    redis.multi()
      .lset(hipacheSessionKey, 0, JSON.stringify(data.sessionPorts))
      .lset(hipacheWebKey, 0, JSON.stringify(data.webPorts))
      .exec(cb);
  };
}

function getSessionAndPorts (container) {
  var servicesToken = container.servicesToken;
  if (!servicesToken) {
    console.log('missing servicesToken!!');
    cb(null, null); // skip missing services token
  }
  else {
    var sessionKey = getSessionKey(container);
    var hipacheSessionKey = getSessionHipacheKey(container);
    var hipacheWebKey = getWebHipacheKey(container);
    console.log('hipacheSessionKey', hipacheSessionKey);
    console.log('hipacheWebKey', hipacheWebKey);
    console.log('sessionKey', sessionKey);
    return function (cb) {
      async.parallel({
        session: sessRedis.hgetall.bind(sessRedis, sessionKey),
        sessionPorts  : redis.lindex.bind(redis, hipacheSessionKey, 0),
        webPorts  : redis.lindex.bind(redis, hipacheWebKey, 0)
      }, cb);
    };
  }
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
function getSessionHipacheKey (container) {
  console.log('frontend:'+container.servicesToken+'.'+domain);
  return 'frontend:'+container.servicesToken+'.'+domain;
}
function getWebHipacheKey (container) {
  console.log('frontend:'+container.webToken+'.'+domain);
  return 'frontend:'+container.webToken+'.'+domain;
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