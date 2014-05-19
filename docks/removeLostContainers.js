var getContainerId = require('../mongodb/getContainerId.js');
var Docker = require('dockerode');
var docker = new Docker({
  host: "http://localhost",
  port: "4242"
});
var removalCnt = 0;
var dry = false;
// [{ "containerId" : "7b1e9782500c8e98df512e065ca19e25e3464b542a1917157b04ca776680970b" }, ...]
var gotContainerIds = function (err, goodContainerIds)  {
  console.log("num good containers: ", goodContainerIds.length);
  docker.listContainers({
    all: true
  }, function (err, containers) {
    console.log("num containers to process: ", containers.length);
    if(err) {
      return console.log("got err: ", err);
    }
    containers.forEach(function (containerInfo) {
      if (!isInArray(containerInfo.Id, goodContainerIds)) {
        removalCnt++;
        if (!dry) {
          console.log("removing ", containerInfo.Id);
          docker.getContainer(containerInfo.Id).remove(onRemoveError);
        }  
      }
    });
    console.log("num good containers: ", goodContainerIds.length);
    console.log("num containers to processed: ", containers.length);
    console.log("removed containers: ", removalCnt);
  });
};

getContainerId(gotContainerIds);


function isInArray(value, array) {
  for (var i = array.length - 1; i >= 0; i--) {
    if(array[i].containerId && array[i].containerId.indexOf(value) > -1) {
      if (array[i].containerId !== value){
        console.log(array[i].containerId, value);
        return false;
      }
      return true;
    }
  }
  return false;
}

function onRemoveError(err) {
  if(err) {
    console.log("removeerr: ", err);
  }
}