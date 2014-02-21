db.users.find().forEach(function (user) {
  if (user.username) {
    var set = {
      lower_username: user.username.toLowerCase()
    };
    print(user.username);
    printjson(set);
    db.users.update({_id:user._id}, {$set:set});
  }
});