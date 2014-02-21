db.images.find().forEach(function (image) {
  var userHasVote = Boolean(db.users.findOne({_id:image.owner, 'votes.runnable':image._id}));
  if (!userHasVote) {
    print('missing vote for', image._id, 'by', image.owner);
    db.users.update({_id:image.owner}, {
      $push: {
        votes: { runnable:image._id }
      }
    }, true);
  }
});