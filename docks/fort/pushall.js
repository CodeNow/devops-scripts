var Docker = require('dockerode');
var docker = new Docker({socketPath: '/var/run/docker.sock'});
var async = require('async');

docker.listImages(function (err, images) {
  if (err) {
    throw err;
  } else {
    var repos = [];
    var failed = [];
    images.forEach(function (image) {
      if (image.RepoTags) {
        repos = repos.concat(image.RepoTags);
      }
      if (image.Repository) {
        repos.push(image.Repository);
      }
    });
    repos = repos.filter(function (repo) {
      return /registry.runnable.com/.test(repo);
    }).map(function (repo) {
      return repo.replace(':latest', '');
    });
    console.log(repos);
    async.eachLimit(repos, 3, function (repo, cb) {
      process.stdout.write('.');
      var image = docker.getImage(repo);
      image.push({}, function (err, stream) {
        if (err) {
          console.error('push err', err);
          failed.push(repo);
          cb();
        } else {
          stream.on('data', function (raw) {
            var data = JSON.parse(raw);
            if (data.error) {
              console.log('data err', data.error);
              failed.push(repo);
            }
          });
          stream.on('error', function (err) {
            console.log('res err', err);
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
  }
});