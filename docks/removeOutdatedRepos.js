var redis = require('redis');
var fs = require('fs');
var decode = require('hex64').decode;
var configs = require('../../lib/configs');
var ip = require('../../lib/ip');
var exec = require('child_process').exec;
var async = require('async');
var client = redis.createClient(configs.redisPort, configs.redisHost);

async.series([
  removeEntry,
  stopDocker,
  editRepositories,
  startDocker,
  addEntry
], done);

var dryrun = true;

function removeEntry (cb) {
  if (dryrun) return cb();
  client.lrem('frontend:docklet.runnable.com', 1, ('http://' + ip + ':4244'), cb);
}

function stopDocker (cb) {
  if (dryrun) return cb();
  exec('service docker stop', cb);
}

function editRepositories (cb) {
  var file = '/var/lib/docker/repositories-aufs';
  var json = JSON.parse(fs.readFileSync(file));
  fs.writeFileSync(file+'-'+Date.now()+'.bak', JSON.stringify(json));

  var repos = json.Repositories;
  var repoKeys = Object.keys(repos);

  // remove old format repos
  repoKeys
    .filter(and(
      startsWith('registry.runnable.com'),
      oldRepo()
    ))
    .forEach(function (key) {
      console.log('deleting:', key);
      delete repos[key];
    });
  // update ip style
  repoKeys
    .filter(startsWith('54.215.162.19'))
    .forEach(function (key) {
      var newKey = key.replace('54.215.162.19', 'registry.runnable.com');
      if (!repos[newKey] && !oldRepo(newKey)) {
        console.log('moving:', key, '->', newKey);
        repos[newKey] = repos[key];
      }
      console.log('deleting:', key);
      delete repos[key];
    });

  if (dryrun) file += '-dryrun'; // DRYRUN writes out to a diff file!
  fs.writeFile(file, JSON.stringify(json), cb);
}

function startDocker (cb) {
  if (dryrun) return cb();
  exec('service docker start', cb);
}

function addEntry () {
  if (dryrun) return cb();
  client.rpush('frontend:docklet.runnable.com', 1, ('http://' + ip + ':4244'), cb);
}

function done (err) {
  if (err) {
    throw err;
  } else {
    console.log('DONE');
  }
}





function startsWith (start) {
  return function (str) {
    return str.indexOf(str) === 0;
  };
}

function and (/* fns */) {
  var fns = Array.prototype.slice.call(arguments);
  return function (item) {
    return fns.reduce(function (memo, fn) {
      return memo && fn(item);
    }, true);
  };
}

function oldRepo () {
  return function (repo) {
    return repo.length !== ('registry.runnable.com/runnable/52766b0a39cb7b3754000021'.length);
  };
}