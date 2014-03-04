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
  this.timeout(0);
  before(function () {
    this.repo = process.env.docker8 ?
      'registry.runnable.com/runnable/53114add52f4df0039412fbb':
      'registry.runnable.com/runnable/UXgzNO_v2oZyAADG';
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
  if (process.env.docker8) {
    it('should create a container', function (done) {
      var self = this;
      var body =  {
        Image: this.repo,
        Volumes: { '/dockworker': {} },
        ExposedPorts: {
          "80/tcp": {},
          "15000/tcp": {}
        },
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
  }
  else {
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
  }
  describe('running container', function () {
    if (process.env.docker8) {
      it('should start', function (done) {
        container.start({
          Binds: ["/home/ubuntu/dockworker:/dockworker:ro"],
          PortBindings: {
            "80/tcp": [{}],
            "15000/tcp": [{}]
          }
        }, done);
      });
      it('should find its ports', function (done) {
        container.inspect(function (err, data) {
          if (err) return done(err);
          var port = data.NetworkSettings.Ports['15000/tcp'][0].HostPort;
          port.should.be.type('string');
          dockworkerUrl = host+':'+port;
          dockworker = request(dockworkerUrl);
          done();
        });
      });
    }
    else {
      it('should start', function (done) {
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
    }
    // dockworker
    describe('dockworker', function () {
      it('should get the containers service token', function (done) {
        var self = this;
        console.log(dockworkerUrl);
        doit();
        function doit () {
          var dockworkerGetToken = dockworker.get('/api/servicesToken')
          dockworkerGetToken.expect(200)
            .end(function (err, res) {
              if (err) {
                if (err.message.indexOf('ECONNRESET')) {
                  return doit(); // try again
                }
                return done(err);
              }
              res.text.should.equal(serviceToken)
              done();
            });
        }
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
});