// migrate docklet ip of containers form one IP to another 
var redis = require('redis').createClient("6379", "localhost");
var count = 0;
var tcount = 0;
var NEW_DOCK_IP = "10.0.2.000";
var OLD_DOCK_IP = "10.0.2.140";

function getSessons() {
  redis.keys("harbourmasterSession:*", function (err, tokens) {
    if(err) {
      console.dir(err);
      return;
    }
    gotKeys(tokens);
  });
}

function gotKeys(tokens) {
  tcount = tokens.length;
  tokens.forEach(function (token, i) {
    redis.hgetall(token, gotSession(token));
  });
}

function gotSession(key) {
  return function (err, data) {
    count++;
    if (err) {
      console.error("error: " +err);
    } else if (data === null) {
      console.error('error: Session not found ' + err);
    } else {
      if (data.docklet === OLD_DOCK_IP) {
        console.log("updating: "+key);
        console.dir(data);
        redis.HMSET(key, "docklet", NEW_DOCK_IP);
      }
    }
    if(count === tcount) {
      redis.quit();
    }
  };
}

getSessons();