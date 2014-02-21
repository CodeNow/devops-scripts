
db.users.find({}, {_id:1, username:1, votes:1}).forEach(function (user) {
  if (user.votes) {
    var removeVotes = [];
    user.votes.forEach(function (vote, i) {
      var imgId = vote.runnable;
      var img = db.images.findOne({_id:imgId}, {_id:1});
      if (!img) {
        removeVotes.push(vote);
      }
    });
    var newVotes = user.votes.filter(function (vote) {
      return !(~removeVotes.indexOf(vote)); // only keep votes that are not in removeVotes
    });
    if (user.votes.length !== newVotes.length) {
      var printVote = function (v) {
        print(v.runnable);
      };
      print('start>>');
      print(user._id);
      print(user.votes.length)
      user.votes.forEach(printVote);
      print(' --');
      print(newVotes.length)
      newVotes.forEach(printVote);
      print('end>>');
      db.users.update({_id:user._id}, {$set:{ votes:newVotes }});
    }
  }
});