console = {log:print}

var sortBy;

var sortBy = function(attr) {
  var inv;
  inv = 1;
  if (attr[0] === '-') {
    attr = attr.slice(1);
    inv = -1;
  }
  return function(a, b) {
    if (a[attr] > b[attr]) {
      return -1 * inv;
    } else {
      if (a[attr] < b[attr]) {
        return 1 * inv;
      } else {
        return 0;
      }
    }
  };
};

var tjid = db.users.findOne({username:'tjmehta'})._id;
var channels = [];
var length = db.images.distinct('tags.channel', {owner:tjid}).length;
db.images.distinct('tags.channel', {owner:tjid}).forEach(function (channelId) {
  var channel = db.channels.findOne({_id:channelId}, {name:1});
  if (channel) {
    channel.count = db.images.count({'tags.channel':channelId});
    channels.push(channel);
  }
});

channels = channels.sort(sortBy('count'));
printjson(channels);
