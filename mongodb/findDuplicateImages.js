var nameHash = {};
db.images.find().forEach(function (img) {
    if (!nameHash[img.name]) {
        nameHash[img.name] = [];
    }
    nameHash[img.name].push(img._id);
});

Object.keys(nameHash).forEach(function (name) {
    var imageIds = nameHash[name];
    if (imageIds.length>1) {
        print("=====start")
        print("name: " + name)
        imageIds.forEach(function (imageId) {
            var hex = imageId.toString().replace(/^ObjectId\("/, '').replace(/"\)$/, '');
            print(hex);
        });
        print("=====end")
    }
});

