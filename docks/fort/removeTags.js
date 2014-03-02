var Docker = require('dockerode');
var docker = new Docker({socketPath: '/var/run/docker.sock'});
var async = require('async');
var decode = require('hex64').decode;

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
    }).filter(function (repo) {
      return repo.split('/').pop().length !== 24;
    });
    console.log(repos);
    async.eachSeries(repos, function (repo, cb) {
      var image = docker.getImage(repo);
      image.remove(cb);
    }, function (err) {
      if (err) {
        throw err;
      }
      console.log('DONE');
    });
  }
});