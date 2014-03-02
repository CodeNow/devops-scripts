var fs = require('fs');
var decode = require('hex64').decode;

var reg = JSON.parse(fs.readFileSync('/var/lib/docker/repositories'));

Object
  .keys(reg)
  .filter(function (key) {
    return key.length === 47;
  })
  .forEach(function (key) {
  var split = key.split('/');
    var id = split.pop();
    split.push(decode(id));
    reg[split.join('/')] = reg[key];
  });

fs.writeFileSync('/var/lib/docker/repositories', JSON.stringify(reg));
