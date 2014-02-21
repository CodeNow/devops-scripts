var hash = {};
var usernames = db.users.distinct('lower_username', {lower_username:{$exists:true}});
usernames.forEach(function (lower) {
  var count = db.users.count({lower_username:lower});
  if (count > 1) {
    db.users.find({lower_username:lower}, {_id:1}).forEach(function (users) {
      hash[lower] = users;
    });
  }
});