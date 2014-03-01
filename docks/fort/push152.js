var Docker = require('dockerode');
var docker = new Docker({socketPath: '/var/run/docker.sock'});
var async = require('async');

var failed = [];
var repos = [ 'registry.runnable.com/runnable/82e50255-38ca-4440-8f0d-2ebd8608a5d5',
  'registry.runnable.com/runnable/UozsbUlX6jcgAABh' ];

async.eachLimit(repos, 3, function (repo, cb) {
  var image = docker.getImage(repo);
  image.push({}, function (err, stream) {
    if (err) {
      console.log('IMAGE', repo);
      failed.push(repo);
      cb();
    } else {
      stream.on('data', function (raw) {
        var data = JSON.parse(raw);
        if (data.error) {
          console.log('DATA', repo);
          failed.push(repo);
        }
      });
      stream.on('error', function (err) {
        console.log('RESP', repo);
        failed.push(repo);
        cb();
      });
      stream.on('end', cb);
    }
  });
}, function (err) {
  if (err) {
    throw err;
  } else {
    console.log('DONE');
    console.log(failed);
    process.exit();
  }
});