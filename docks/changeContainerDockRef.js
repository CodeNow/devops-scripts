// migrate docklet ip of containers form one IP to another 
var redis = require('redis').createClient("6379", "localhost");
var count = 0;
var keyCount = 0;
var newDockIp = "10.0.2.000";
var oldDockIp = "10.0.2.140";

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
  keyCount = keys.length;
  keys.forEach(function (key, i) {
    redis.hgetall(key, gotKey(key));
  });
}

function gotKey(key) {
  return function (err, data) {
    count++;
    if (err) {
      console.dir(err);
    } else if (data === null) {
      console.error('error: Session not found ' + err);
    } else {
      if (data.docklet === oldDockIp) {
        console.log("updating: "+key);
        redis.HMSET(key, "docklet", newDockIp);
      }
    }
    if(count === keyCount) {
      redis.quit();
    }
  };
}

getSessionsKeys();
