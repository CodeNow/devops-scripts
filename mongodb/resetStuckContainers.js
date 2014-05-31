var console= {log:print};
var hourAgo = new ISODate();

hourAgo.setHours(hourAgo.getHours() - 1);

db.containers.find({
  status: {
    $nin: ['Draft', 'Finished']
  },
  last_write: {
    $lte: hourAgo
  }
},
{
  status:1,
  last_write:1,
  commit_error:1
}).forEach(function (container) {
  db.containers.update({ _id: container._id }, {
    $set: {
      status: 'Draft',
      commit_error: ''
    }
  });
});