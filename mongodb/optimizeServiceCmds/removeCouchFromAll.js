var query = {
  service_cmds: /couchdb/
};
var fields = {
  service_cmds: 1
};
db.images.find(query, fields).forEach(function (image) {
  var new_service_cmds = image.service_cmds.replace('couchdb;', '').trim();
  print(['update',image._id,new_service_cmds].join(' '));
  db.images.update({ _id: image._id }, {
    $set: {
      service_cmds: new_service_cmds
    }
  });
});