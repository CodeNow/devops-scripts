var Docker = require('dockerode');
var docker = new Docker({socketPath: '/var/run/docker.sock'});
var async = require('async');

var failed = [];
var repos = [ 'registry.runnable.com/runnable/UvP0W5o6ncBVAAAW',
  'registry.runnable.com/runnable/UvPyae56Bb5SAACK',
  'registry.runnable.com/runnable/3b31ff3c-85b6-49a0-a2d6-90e959924a02',
  'registry.runnable.com/runnable/34ad0b3a-8785-4335-9b07-d28cfe549aea',
  'registry.runnable.com/runnable/UvPxFfWnIstTAABF',
  'registry.runnable.com/runnable/fe69d688-10d9-4106-b2eb-69db5e46fa50',
  'registry.runnable.com/runnable/UvPrNyIq_5pSAABi',
  'registry.runnable.com/runnable/7d7793ac-bd98-4ae2-8ea7-29c2c5674708',
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