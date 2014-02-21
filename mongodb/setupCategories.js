var categoryMap = {
  'Node.js': [
    'nodejs',
    'express',
    'mongoose',
    'node-mongodb-native',
    'paypal',
    'socketio',
    'google',
    'evernote',
    'everyauth',
    'ejs',
    'rendr',
    'twitter'
  ],
  'PHP': [
    'CakePHP',
    'php-mysql',
    'php-facebook',
    'PHP',
    'codeigniter',
    'imagemagick'
  ],
  'Python': [

  ],
  'Javascript': [
    'angularjs',
    'jQuery',
    'pagination',
    'slider'
  ],
  'Frameworks': [
    'CakePHP',
    'codeigniter',
    'express'
  ],
  'Effects': [
    'slider'
  ],
  'UI': [
    'pagination'
  ],
  'Payments': [
    'paypal'
  ],
  'Social': [
    'facebook',
    'twitter',
    'google'
  ],
  'Databases': [
    'mongoose',
    'node-mongodb-native',
    'php-mysql',
    'sequelize'
  ],
  'Forms': [
    'validation'
  ]
};

function createDoc (name, description) {
  var doc = {
    name: name,
    alias: [name.toLowerCase()]
  };
  if (description) {
    doc.description = description;
  }
  return doc;
}

var categoryNames = Object.keys(categoryMap);
var channelDocs = [];

function channelExists (checkName) {
  var found = null;
  channelDocs.some(function (doc) {
    if (doc.name == checkName) {
      found = doc;
      return true;
    }
  });
  return found;
}

categoryNames.forEach(function (catName) {
  var channelNames = categoryMap[catName];
  channelNames.forEach(function (channName) {
    var existing = channelExists(channName);
    if (existing) {
      existing.category.push(createDoc(catName));
    }
    else {
      var channel = createDoc(channName, 'placeholder description so that it takes up space')
      channel.category = [createDoc(catName)];
      channelDocs.push(channel);
    }
  });
});

channelDocs.forEach(function (doc) {
  print(doc.name);
  db.channels.update({name:doc.name}, doc, true);
});