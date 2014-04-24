// migrate docklet ip of containers form one IP to another 
var redis = require('redis').createClient("6379", "localhost");
var count = 0;
var keyCount = 0;
var newDockIp = "10.0.2.000";
var oldDockIp = "10.0.2.000";
var multi = redis.multi();
var numToUpdate = 0;

function getSessionsKeys() {
  console.log("getting harbourmasterSession Keys");
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
  console.log("got keys. num: "+keyCount);
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
        numToUpdate++;
        multi.HMSET(key, "docklet", newDockIp);
      }
    }
    if(count === keyCount) {
      console.log("updateing "+numToUpdate+" out of " + keyCount);
      multi.exec(function (err, replies) {
        if(err) {
          console.dir(err);
          redis.quit();
          return;
        }
        console.log("finshed. num replies: "+replies.length);
        redis.quit();
      });
    }
  };
}

getSessionsKeys();
