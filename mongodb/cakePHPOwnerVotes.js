db.images.find({ 'tags.name':'CakePHP' }).forEach(function (image) {
  db.users.update({
    _id:image.owner
  }, {
    $push: {
      votes: {
        runnable:image._id
      }
    }
  });
});