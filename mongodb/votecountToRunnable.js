var console = { log: print };
var runnableVotes = {};

db.users.find({votes:{$not:{$size:0}}}, { _id:1, votes:1 }).forEach(function (user) {
  user.votes.forEach(function (vote) {
    var rid = vote.runnable.toString().replace('ObjectId("', '').replace('")', '');
    var userIsOwner = db.images.findOne({ _id:vote.runnable, owner:user._id }, {_id:1});
    if (!userIsOwner) {
      runnableVotes[rid] = Boolean(runnableVotes[rid]) ? runnableVotes[rid]+1 : 1;
    }
  });
});

Object.keys(runnableVotes).forEach(function (rid) {
  print(rid + " " + runnableVotes[rid]);
  var query = { _id:ObjectId(rid) };
  var update = {
    $set: { votes:runnableVotes[rid] }
  };
  db.images.update(query, update);
});