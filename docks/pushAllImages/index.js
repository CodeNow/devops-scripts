var _ = require('lodash');
var async = require('async');
var request = require('request');
var url = require('url');
var Docker = require('dockerode');
var docker_connection = {
  socketPath: process.env.DOCKER_HOST
};
if (process.env.DOCKER_HOST) {
  var url = url.parse(process.env.DOCKER_HOST);
  docker_connection = {
    host: url.protocol + '//' + url.hostname,
    port: url.port
  };
}

var docker = new Docker(docker_connection);
var none_string = '<none>:<none>';
var opts = {
  testing: true
};

main();

function pushAllImages(callback) {
  async.waterfall([
    docker.listImages.bind(docker),
    filterImagesNotLatestInRegistry,
    pushImagesToRegistry
  ], callback);
}

function filterImagesNotLatestInRegistry(images, callback) {
  async.filterSeries(
    images,
    imageRegistryCheck,
    function (results) {
      callback(null, results);
    });
}

function checkAncestry(image, registry, name, callback) {
  // return callback(true) if the image needs to be sync'd.
  request('http://' + registry + '/v1/repositories/' + name + '/tags',
    function (err, res, body) {
      if (err || res.statusCode !== 200) {
        console.log('could not pull up tags for', res.statusCode, name);
        return callback(false);
      }
      body = JSON.parse(body);
      if (body.length === 0 || body.latest !== image.Id) {
        console.log('no remote ancestry or latest does not match', body[0], image.Id);
        return callback(true);
      }
      // if we're here, the latest tag does match, and we shouldn't push
      console.log('ancestry matches. go us!');
      callback(false);
    });
}

function imageRegistryCheck(image, callback) {
  // return callback(true) if the image needs to be sync'd.
  if (image.RepoTags.length === 0) {
    return callback(false);
  }

  // var fullTag = _.findWhere(image.RepoTags, { length: 62 });
  var fullTag = _.findWhere(image.RepoTags, function (tag) {
    return tag.indexOf('localhost') !== -1;
  });
  if (!fullTag) {
    return callback();
  }

  var tag = fullTag.substr(0, fullTag.lastIndexOf(':'));
  var registry = tag.substr(0, tag.indexOf('/'));
  var name = tag.substr(tag.indexOf('/') + 1);

  request('http://' + registry + '/v1/images/' + image.Id + '/json',
    function (err, res, body) {
      if (err) {
        console.log('could not check tags for', image.Id);
        return callback(false);
      }
      if (res.statusCode === 200) {
        console.log('need to check more:', image.Id);
        checkAncestry(image, registry, name, callback);
      }
      else if (res.statusCode === 404) {
        console.log('need to push to registry', res.statusCode, image.Id);
        callback(true);
      } else {
        console.error('something went really wrong...');
        callback(false);
      }
    });
}

function pushImagesToRegistry(images, callback) {
  async.eachSeries(
    images,
    dockerRegistryPush,
    callback);
}

function dockerRegistryPush(image, callback) {
  var fullTag = _.findWhere(image.RepoTags, function (tag) {
    return tag.indexOf('localhost') !== -1;
  });
  var tag = fullTag.substr(0, fullTag.lastIndexOf(':'));
  var registry = tag.substr(0, tag.indexOf('/'));
  var name = tag.substr(tag.indexOf('/') + 1);

  console.log((opts.testing ? '[test]' : ''), 'PUSHING IMAGE:', name);
  if (opts.testing) {
    return callback();
  } else {
    docker.getImage(image).push({}, callback);
  }
}

function processArgs(callback) {
  if (process.argv.length < 3 || process.argv[2] === 'help') {
    return callback('node index.js [test|push|help]\n\ntest - simulate push\npush - push to index\nhelp - show this help\n' +
      'DOCKER_HOST must also be set in your environment, e.g. "http://127.0.0.1:4243" or "/var/run/docker.dock"');
  } else if (process.argv[2] === 'push') {
    opts.testing = false;
  }
  callback();
}

function main() {
  async.series([
    processArgs,
    pushAllImages
  ], function (err) {
    if (err) {
      console.error(err);
      process.exit(-1);
    }
  });
}
