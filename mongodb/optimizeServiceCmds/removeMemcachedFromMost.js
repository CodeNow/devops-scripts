
var channelNames = [
  'memcached',
  'memcache'
];

var keywords = channelNames.concat([
]);

var channelIds = channelNames
  .map(function (name) {
    var channel = db.channels.findOne({ aliases: name });
    return channel._id;
  });

var blackChannelNames = [
];

var blackKeywords = blackChannelNames.concat([]);

var blackChannelIds = blackChannelNames
  .map(function (name) {
    var channel = db.channels.findOne({ aliases: name });
    return channel._id;
  });

printjson(imageNames('memcached'));

function imageNames (dbname) {
  var re = new RegExp(dbname);
  var query = { service_cmds: re };
  return db.images.find(query, {name:1, tags:1, service_cmds:1}).toArray()
    .filter(shouldRemoveMem)
    // .map(nameWithTags); //debug
    .forEach(removeMem);
}

function removeMem (image) {
  var new_service_cmds = image.service_cmds
    .replace('memcached -d -u www-data;', '')
    .trim();
  print(['update',image._id,new_service_cmds].join(' '));
  db.images.update({ _id: image._id }, {
    $set: {
      service_cmds: new_service_cmds
    }
  });
}

function shouldRemoveMem (image) {
  return (blacklisted(image) || !keepMem(image));
}

function blacklisted (image) {
  var lowerTitle = image.name.toLowerCase();

  var hasBlackTag = image.tags.some(function (tag) {
    return blackChannelIds.some(toStringEquals(tag.channel));
  });
  var hasBlackTitle = blackKeywords.some(function (word) {
    return ~lowerTitle.indexOf(word);
  });

  return hasBlackTag || hasBlackTitle;
}

function keepMem (image) {
  var lowerTitle = image.name.toLowerCase();

  var hasKeepTag = image.tags.some(function (tag) {
    return channelIds.some(toStringEquals(tag.channel));
  });
  var hasKeepTitle = keywords.some(function (word) {
    return ~lowerTitle.indexOf(word);
  });

  return hasKeepTag || hasKeepTitle;
}

function nameWithTags (image) {
  if (image.tags) image.tags = image.tags.map(toChannelName);
  return image.name + '   [ '+image.tags.join(' ][ ')+' ]';
}

function toChannelName (tag) {
  var channel = db.channels.findOne({ _id: tag.channel });
  return channel.name;
}

function pluck (key) {
  return function (obj) {
    return obj[key];
  };
}

function toString (thing) {
  return (thing && thing.toString) ? thing.toString() : '';
}

function toStringEquals (o1) {
  return function (o2) {
    var s1 = o1.toString();
    var s2 = o2.toString();
    if (s1 === '[object Object]' || s2 === '[object Object]') {
      throw new Error('toStringEquals found something bad');
    }
    return s1 === s2;
  };
}