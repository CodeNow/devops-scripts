var hash = {};
var usernames = db.users.distinct('lower_username', {lower_username:{$exists:true}});
usernames.forEach(function (lower) {
  var count = db.users.count({lower_username:lower});
  if (count > 1) {
    hash[lower] = [];
    db.users.find({lower_username:lower}, {_id:1, username:1}).forEach(function (user) {
      hash[lower].push(user);
    });
  }
});

Object.keys(hash).forEach(function (lower) {
  hash[lower].forEach(function (user, i) {
    if (i === 0) return; // keep username
    var newusername = user.username+i;
    var newlower = newusername.toLowerCase();
    print(newusername);
    db.users.update({_id:user._id}, {$set:{username:newusername, lower_username:newlower}});
  });
});