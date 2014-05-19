var getContainerId = require('../mongodb/getContainerId.js');
var Docker = require('dockerode');
var docker = new Docker({
  host: "localhost",
  port: "4242"
});

getContainerId(gotContainerIds);


function isInArray(value, array) {
  return array.indexOf(value) > -1;
}

// [{ "containerId" : "7b1e9782500c8e98df512e065ca19e25e3464b542a1917157b04ca776680970b" }, ...]
var gotContainerIds = function (containerIds)  {
docker.listContainers({
    all: true
  }, function (err, containers) {
    containers.forEach(function (containerInfo) {
      console.log(containerInfo.Id);
    });
  });
};