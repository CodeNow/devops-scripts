db.images.find({'tags.name': 'php'}).forEach(function (image) {
  image.files = null;
  print(']]]]-------IMAGE START----------');
  printjson(image)
  db.users.find({'votes.runnable':image._id}).forEach(function (user) {
    print('>>--VOTERS START-');
    user.votes = null;
    printjson(user);
    print('<<--VOTERS END-');
  });
  print('[---------IMAGE END----------')
});