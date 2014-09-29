// anandp
// this module used to do docker view processes

// Used because 2 commands come in before user gets to type.
// service commands and the echo below
http = require('http');

var timePing = 500;
var number = 2;

var failCount = 0;
l = false;
function log (item) {
  if (l) console.log(item);
}

function createContainer() {
  start = new Date();
  log("trying to create from: google/nodejs-hello");
var exec = require('child_process').exec,
child;
child = exec('sudo docker run -d -p 8080 google/nodejs-hello',
  function (error, stdout, stderr) {
    if (error !== null) {
      console.log('createContainer error: ' + error);
    }
    var container = stdout.replace(/(\r\n|\n|\r)/gm," ").trim();
    log("created container: "+ container);
    log('createContainer stderr: ' + stderr);
    checkPorts(container);
  });
}

var failCount = 0;
function checkPorts (container) {
  var exec = require('child_process').exec,
  child;
  child = exec('sudo docker port '+container+" 8080 | sed s/.*://",
    function (error, stdout, stderr) {
      log('checkPorts stdout: ' + stdout);
      log('checkPorts stderr: ' + stderr);
      if (error !== null) {
        console.log('createContainer error: ' + error);
      }
      var port = stdout.replace(/(\r\n|\n|\r)/gm," ").trim();
      log('Got port 8080: '+port);
      pingContiner(port, container);
    });
}

function pingContiner(port, container) {
  log('pingContiner port: ' + port);
  var options = {
    hostname: 'localhost',
    port: port,
    path: '/',
    method: 'GET'
  };

  var req = http.request(options, function(res) {
    log("request: ");
    log('STATUS: ' + res.statusCode);
    if (res.statusCode !== 200) {
      console.log("ERR in http request"+ res.statusCode);
    }
    res.setEncoding('utf8');
    res.on('data', function (chunk) {
      if (~chunk.indexOf('Hello World')) {
        console.log("GOOD");
        var diff = new Date() - start;
        console.log("done creating: " + diff);
        checkIfDone();
      } else {
        console.log('ERROR message from server: ' + chunk);
      }
    });
  });
  req.on('error', function(e) {
    log('problem with request: ' + e.toString());
    if (failCount++ < 10000) {
      setTimeout(function () {
        pingContiner(port, container);
      }, timePing);
    } else {
      console.log('No portmapping');
    }
  });
  req.end();
}

function destroyContainer() {
  var exec = require('child_process').exec,
    child;

  child = exec('sudo docker kill google/nodejs-hello',
  function (error, stdout, stderr) {
    log('destroyContainer stdout: ' + stdout);
    log('destroyContainer stderr: ' + stderr);
    if (error !== null) {
      console.log('destroyContainer error: ' + error);
    }
  });
  //checkIfDone();
}

function checkIfDone() {
  if (number-- > 0) {
    createContainer();
  } else {
    console.log('done took', new Date() - globalStart, 'for', number);
  }
}
log("started");
var globalStart = new Date();
createContainer();
