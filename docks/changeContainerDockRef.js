// migrate docklet ip of containers form one IP to another 
var redis = require('redis').createClient("6379", "localhost");
var count = 0;
var key_count = 0;
var NEW_DOCK_IP = "10.0.2.000";
var OLD_DOCK_IP = "10.0.2.140";

function getSessionsKeys() {
  redis.keys("harbourmasterSession:*", function (err, keys) {
    if(err) {
      console.dir(err);
      return;
    }
    gotKeys(keys);
  });
}

function gotKeys(keys) {
  key_count = keys.length;
  keys.forEach(function (key, i) {
    redis.hgetall(key, gotSession(key));
  });
}

function gotSession(key) {
  return function (err, data) {
    count++;
    if (err) {
      console.dir(err);
    } else if (data === null) {
      console.error('error: Session not found ' + err);
    } else {
      if (data.docklet === OLD_DOCK_IP) {
        console.log("updating: "+key);
        console.dir(data);
        redis.HMSET(key, "docklet", NEW_DOCK_IP);
      }
    }
    if(count === key_count) {
      redis.quit();
    }
  };
}

getSessionsKeys();