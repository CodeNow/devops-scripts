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
  testing: true,
  verbose: false
};

main();

function pushAllImages(callback) {
  if (opts.verbose) {
    console.log('pushAllImages()...');
  }
  async.waterfall([
    docker.listImages.bind(docker),
    filterImagesNotLatestInRegistry,
    pushImagesToRegistry
  ], callback);
}

function filterImagesNotLatestInRegistry(images, callback) {
  if (opts.verbose) {
    console.log('filterImagesNotLatestInRegistry()...');
  }
  async.filterSeries(
    images,
    imageRegistryCheck,
    function (results) {
      callback(null, results);
    });
}

function pullImage(registry, name, callback) {
  if (opts.verbose) {
    console.log('pullImage()...');
  }
  console.log((opts.testing ? '[test]' : ''), 'PULLING IMAGE:', registry + '/' + name);
  if (opts.testing) {
    callback(false);
  } else {
    docker.pull(registry + '/' + name, function (err, data) {
      if (err) {
        console.log(err);
      }
      callback(false);
    });
  }
}

function checkAncestry(image, latestTag, registry, name, callback) {
  if (opts.verbose) {
    console.log('checkAncestry()...');
  }
  // we are going to simply push the image from here IFF the name has our ID, but not the latest
  request('http://' + registry + '/v1/images/' + latestTag + '/ancestry',
    function (err, res, body) {
      if (err || res.statusCode !== 200) {
        if (opts.verbose) console.log('could not pull up tags for', res.statusCode, name);
        return callback(false);
      }
      body = JSON.parse(body);
      if (body.length === 0 || body.indexOf(image.Id) === -1) {
        if (opts.verbose) console.log('local image is not in repository:latest ancestry');
        return callback(false);
      } else if (body.indexOf(image.Id) > 0) {
        if (opts.verbose) console.log('need to pull image', registry + '/' + name);
        pullImage(registry, name, callback);
      } else {
        console.log('I have no idea what to do with this image', image.Id, registry, name);
        callback(false);
      }
    });
}

function checkTags(image, registry, name, callback) {
  if (opts.verbose) {
    console.log('checkTags()...');
  }
  // return callback(true) if the image needs to be sync'd.
  request('http://' + registry + '/v1/repositories/' + name + '/tags',
    function (err, res, body) {
      if (err || res.statusCode !== 200) {
        if (opts.verbose) console.log('could not pull up tags for', res.statusCode, name);
        return callback(false);
      }
      body = JSON.parse(body);
      if (body.length === 0 || body.latest !== image.Id) {
        // this is where we can push the image IFF the image ID is in the ancestry, but not latest
        if (opts.verbose) console.log('no remote tags or latest does not match', name);
        checkAncestry(image, body.latest, registry, name, callback);
      } else {
        // if we're here, the latest tag does match, and we shouldn't push
        if (opts.verbose) console.log('lastest matches. go us!', name);
        callback(false);
      }
    });
}

function imageRegistryCheck(image, callback) {
  if (opts.verbose) {
    console.log('imageRegistryCheck()...');
  }
  // return callback(true) if the image needs to be sync'd.
  if (image.RepoTags.length === 0) {
    return callback(false);
  }

  // this switch this out for testing localhost images
  var fullTag = _.findWhere(image.RepoTags, { length: 62 });
  // var fullTag = _.findWhere(image.RepoTags, function (tag) {
  //   return tag.indexOf('localhost') !== -1;
  // });
  if (!fullTag) {
    return callback(false);
  }

  var tag = fullTag.substr(0, fullTag.lastIndexOf(':'));
  var registry = tag.substr(0, tag.indexOf('/'));
  var name = tag.substr(tag.indexOf('/') + 1);

  request('http://' + registry + '/v1/images/' + image.Id + '/json',
    function (err, res, body) {
      if (err) {
        if (opts.verbose) console.log('could not check tags for', name);
        return callback(false);
      }
      if (res.statusCode === 200) {
        if (opts.verbose) console.log('need to check more:', name);
        checkTags(image, registry, name, callback);
      }
      else if (res.statusCode === 404) {
        if (opts.verbose) console.log('need to push to registry', res.statusCode, name);
        callback(true);
      } else {
        console.error('something went really wrong...');
        callback(false);
      }
    });
}

function pushImagesToRegistry(images, callback) {
  if (opts.verbose) {
    console.log('pushImagesToRegistry()...');
  }
  async.eachSeries(
    images,
    dockerRegistryPush,
    callback);
}

function dockerRegistryPush(image, callback) {
  if (opts.verbose) {
    console.log('dockerRegistryPush()...');
  }
  // this switch this out for testing localhost images
  var fullTag = _.findWhere(image.RepoTags, { length: 62 });
  // var fullTag = _.findWhere(image.RepoTags, function (tag) {
  //   return tag.indexOf('localhost') !== -1;
  // });
  var tag = fullTag.substr(0, fullTag.lastIndexOf(':'));
  var registry = tag.substr(0, tag.indexOf('/'));
  var name = tag.substr(tag.indexOf('/') + 1);

  console.log((opts.testing ? '[test]' : ''), 'PUSHING IMAGE:', registry + '/' + name);
  if (opts.testing) {
    callback();
  } else {
    var _i = docker.getImage(registry + '/' + name);
    _i.push({}, callback);
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
    } else {
      console.log('done!');
      process.exit(0);
    }
  });
}
