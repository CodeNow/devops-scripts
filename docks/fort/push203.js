var Docker = require('dockerode');
var docker = new Docker({socketPath: '/var/run/docker.sock'});
var async = require('async');

var failed = [];
var repos = [ 'registry.runnable.com/runnable/UuC05N1h_QlLAAEr',
  'registry.runnable.com/runnable/6b6c2214-b482-4899-a53b-eafb128fdc48',
  'registry.runnable.com/runnable/bd77ff72-7543-4dbb-bac8-885a1749ad62',
  'registry.runnable.com/runnable/cafc5f0f-16b6-42b1-a599-0896dfe0f6a6',
  'registry.runnable.com/runnable/82e50255-38ca-4440-8f0d-2ebd8608a5d5',
  'registry.runnable.com/runnable/UozsbUlX6jcgAABh' ];

async.eachLimit(repos, 3, function (repo, cb) {
  process.stdout.write('.');
  var image = docker.getImage(repo);
  image.push({}, function (err, stream) {
    if (err) {
      failed.push(repo);
      cb();
    } else {
      stream.on('data', function (raw) {
        var data = JSON.parse(raw);
        if (data.error) {
          failed.push(repo);
        }
      });
      stream.on('error', function (err) {
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