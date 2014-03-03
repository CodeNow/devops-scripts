var request = require('supertest');
var Docker = require('dockerode');
var host = 'localhost';
var dockletUrl = function (path) {
  path = path || '';
  var domain = 'http://'+host+':4244';
  return domain+path;
};
var dockerUrl = function (path) {
  path = path || '';
  var domain = 'http://'+host+':4243';
  return domain+path;
};
var docker = new Docker(dockerUrl());

var ip = require("os").networkInterfaces()[configs.networkInterface].filter(function(iface) {
  return iface.family === "IPv4";
})[0].address;

var container;

describe('dockletUrl', function () {
  before(function () {
    this.repo = 'registry.runnable.com/UvKWVfRki308AAAh';
  });

  it('should find a container', function (done) {
    request.post(dockletUrl('/find'))
      .send({ repo: this.repo })
      .expect(200, function (res) {
        res.body.should.equal(ip);
      })
      .end(done);
  });
  var createBody = { Image: 'base',
    Volumes: { '/dockworker': {} },
    PortSpecs: [ '80', '15000' ],
    Cmd: [ 'node', '/dockworker' ],
    Env: [ 'STOP_URL=http://localhost:4243/containers/services-f5d237ac-f2bd-4848-a1f0-655713e1b889/stop' ]
  };
  it('should create a container', function (done) {
    var body = createBody;

    docker.createContainer(body, function (err, body) {
      if (err) return done(err);
      container = body;
    });
  });
  describe('running container', function () {
    it('should start a container', function (done) {
      container.start(done);
    });
  });
  it('should find a containers ports', function () {

  });


  describe('dockworker', function () {
    it('should get the containers service token', function () {

    });
    it('should get connect to the terminal and echo back', function () {

    });
  });
});