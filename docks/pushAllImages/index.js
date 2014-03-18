var _ = require('lodash');
var async = require('async');
var Docker = require('dockerode');
var docker_connection = {
  socketPath: process.env.DOCKER_HOST
};
if (process.env.DOCKER_HOST) {
  var host = process.env.DOCKER_HOST;
  var tcp_test = /(.+):\/\/(.+):([0-9]+)/;
  if (tcp_test.test(host)) {
    host = host.split(':');
    docker_connection = {
      host: host[0] + ':' + host[1],
      port: host[2]
    };
  }
}
var docker = new Docker(docker_connection);
var none_string = '<none>:<none>';
var opts = {
  testing: true
};

main();

function pushTag (name, callback) {
  if (!name || name === none_string) {
    return callback();
  }
  if (opts.testing) {
    console.log('TESTING: PUSHING IMAGE', name);
    return callback();
  } else {
    var image = docker.getImage(name); // sync call to use image
    image.push({}, callback);
  }
}

function dockerPush(image, callback) {
  if (image.RepoTags.length === 0) {
    return callback();
  }

  pushTag(
    _.findWhere(image.RepoTags, { length: 55 }),
    callback);
}

function pushImages(images, callback) {
  async.eachLimit(
    images,
    5,
    dockerPush,
    callback);
}

function pushAllImages(callback) {
  async.waterfall([
    docker.listImages.bind(docker),
    pushImages
  ], callback);
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
