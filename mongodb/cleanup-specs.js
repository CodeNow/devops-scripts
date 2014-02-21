db.specifications.find().forEach(function (spec) {
  if (!spec.instructions || !spec.requirements || spec.requirements.length === 0) {
    db.specifications.remove({_id:spec._id});
  };
});