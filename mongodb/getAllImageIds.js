db.images.find({}, {_id:1}).forEach(function (image) {
  print(image._id);
});