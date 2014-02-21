db.users.update({
  password:{$exists:true},
  $or:[
    {permission_level:{$exists:false}},
    {permission_level:0}
  ]
}, {
  $set: {permission_level:1}
}, {
  multi:true
});