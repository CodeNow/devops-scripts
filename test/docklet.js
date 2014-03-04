var request = require('supertest');
var Docker = require('dockerode');
var host = 'http://localhost';
var docklet = request(host+':4244');
var dockworker, dockworkerUrl;
var docker = new Docker({
  host: host,
  port: 4243
});
var uuid = require('uuid');
var ShoeClient = require('./lib/ShoeClient');
var MuxDemux = require('mux-demux');

var ip = require("os").networkInterfaces().eth0.filter(function(iface) {
  return iface.family === "IPv4";
})[0].address;

var container;
function toEnv (obj) {
  return Object.keys(obj).reduce(function (env, key) {
    env.push(key+'='+obj[key]);
    return env;
  }, []);
}

var serviceToken = 'services-' + uuid.v4();
describe('docklet', function () {
  before(function () {
    this.repo = 'registry.runnable.com/runnable/UvKWVfRki308AAAh';
  });

  it('should find a container', function (done) {
    docklet.post('/find')
      .send({ repo: this.repo })
      .expect(200)
      .end(function (err, res) {
        if (err) return done(err);
        res.body.should.equal(ip);
        done();
      });
  });
  it('should create a container', function (done) {
    var self = this;
    var body =  {
      Image: this.repo,
      Volumes: { '/dockworker': {} },
      PortSpecs: [ '80', '15000' ],
      Cmd: [ '/dockworker/bin/node', '/dockworker' ],
      Env: toEnv({
        SERVICES_TOKEN: serviceToken,
        RUNNABLE_START_CMD: 'npm start'
      })
    };
    docker.createContainer(body, function (err, body) {
      if (err) return done(err);
      container = body;
      done();
    });
  });
  describe('running container', function () {
    it('should start', function (done) {
      this.timeout(10*1000);
      container.start({
        Binds: ["/home/ubuntu/dockworker:/dockworker:ro"]
      }, done);
    });
    it('should find its ports', function (done) {
      container.inspect(function (err, data) {
        if (err) return done(err);
        var port = data.NetworkSettings.PortMapping.Tcp[15000];
        port.should.be.type('string');
        dockworkerUrl = host+':'+port;
        dockworker = request(dockworkerUrl);
        done();
      });
    });
    // dockworker
    it('should get the containers service token', function (done) {
      var self = this;
      dockworker.get('/api/servicesToken')
        .expect(200)
        .end(function (err, res) {
          if (err) return done(err);
          res.text.should.equal(serviceToken)
          done();
        });
    });
    it('should run echo', function (done) {
      var socket = 'ws://'+dockworkerUrl.split('//')[1];
      var stream = new ShoeClient(socket+'/streams/terminal');
      var muxDemux = new MuxDemux(onStream);
      stream.pipe(muxDemux).pipe(stream);
      function onStream(stream) {
        if (stream.meta === 'terminal') {
          onTerminal(stream);
        }
      }
      function onTerminal(stream) {
        var count = 0;
        stream.on('data', function (data) {
          if (/npm start\r\n/.test(data)) {
            done();
          }
        });
        stream.write('echo $RUNNABLE_START_CMD\n');
      }
    });
  });
});