db.images.find().forEach(function (image) {
  var lowerTags = [];
  if (!image.tags) {
    print(image.name);
  }
  var notAllTagsLower = false;
  image.tags.forEach(function (tag) {
    var lower = tag.name.toLowerCase()
    lowerTags.push({name:lower});
    notAllTagsLower = (tag.name != lower) || notAllTagsLower;
  });
  if (notAllTagsLower) {
    print(lowerTags);
    db.images.update({_id:image._id}, {$set:{tags:lowerTags}});
  }
});

// db.images.find().forEach(function (image) {
//   var tagsAreStrings = image.tags.some(function (tag) {
//     return typeof tag == 'string';
//   });
//   if (tagsAreStrings) {
//     var objTags = image.tags.map(function (tag) {
//       return {name:tag, _id: new ObjectId()};
//     });
//     print(objTags);
//     // db.images.update({_id:image._id}, {$set:{tags:objTags}});
//   }
// })