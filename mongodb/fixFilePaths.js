db.images.find().forEach(function (image) {
  print(image._id);
  var corrected = false;
  var correctFiles = image.files.map(function (file) {
    print(' '+file.path);
    if (file.path[0] !== '/') {
      file.path = '/'+file.path;
      corrected = true;
      print('  '+file.path);
    }
    return file;
  });
  if (corrected) {
    db.images.update({
      _id: image._id
    }, {
      $set: {
        files:correctFiles
      }
    });
  }
});

db.containers.find().forEach(function (container) {
  print(container._id);
  var corrected = false;
  var correctFiles = container.files.map(function (file) {
    print(' '+file.path);
    if (file.path[0] !== '/') {
      file.path = '/'+file.path;
      corrected = true;
      print('  '+file.path);
    }
    return file;
  });
  if (corrected) {
    db.containers.update({
      _id: container._id
    }, {
      $set: {
        files:correctFiles
      }
    });
  }
});