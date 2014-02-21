var languagesId = db.categories.findOne({aliases:'languages'})._id;
var cppNotLanguage = {
  aliases:'c++',
  'tags.category': {$ne:languagesId}
};
var javaNotLanguage = {
  aliases:'java',
  'tags.category': {$ne:languagesId}
};
var tagAsLanguage = {
  $push: {
    tags: {
      _id: new ObjectId(),
      category:languagesId
    }
  }
};

db.channels.update(cppNotLanguage, tagAsLanguage);
db.channels.update(javaNotLanguage, tagAsLanguage);

var featuredId = db.categories.findOne({aliases:'featured'})._id;
var cppNotFeatured = {
  aliases:'c++',
  'tags.category': {$ne:featuredId}
};
var javaNotFeatured = {
  aliases:'java',
  'tags.category': {$ne:featuredId}
};
var expressNotFeatured = {
  aliases:'express',
  'tags.category': {$ne:featuredId}
};
var tagAsFeatured = {
  $push: {
    tags: {
      _id: new ObjectId(),
      category:featuredId
    }
  }
};

db.channels.update(cppNotFeatured, tagAsFeatured);
db.channels.update(javaNotFeatured, tagAsFeatured);
db.channels.update(expressNotFeatured, tagAsFeatured);

// java description
db.channels.update({aliases:'java'}, {$set:{description:'Computer programming language'}})