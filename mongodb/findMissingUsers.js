users = {};
missingUserIds = [];
db.images.find({}, {owner:1}).forEach(function (image) {
  if (!users[image.owner]) {
    users[image.owner] = true;
    if (!db.users.findOne({_id:image.owner}, {_id:1})) {
      missingUserIds.push(image.owner);
    }
  }
});

printjson(missingUserIds)