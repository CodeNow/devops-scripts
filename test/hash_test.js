var fs = require('fs');
var crypto = require('crypto');
var md5 = require('md5');
var file = fs.readFileSync('./large-dockerfile');
file = file.toString();

var avg = 0;
var count = 0;

for (i = 0; i < 10000; i++) {
  var start = new Date();
  var shasum = crypto.createHash('sha1');
  shasum.update(file, 'utf8');
  var result = shasum.digest('hex');
  avg += new Date() - start;
  count++;
}
console.log('avg time crypto sha1', avg/count, avg, count);

avg = 0;
count = 0;
for (i = 0; i < 10000; i++) {
  var start = new Date();
  var hmd5 = crypto.createHash('md5');
  hmd5.update(file, 'utf8');
  var result = hmd5.digest('hex');
  avg += new Date() - start;
  count++;
}
console.log('avg time crypto md5', avg/count, avg, count);

avg = 0;
count = 0;
for (i = 0; i < 10000; i++) {
  var start = new Date();
  var result = md5.digest_s(file);
  avg += new Date() - start;
  count++;
}
console.log('avg time md5', avg/count, avg, count);
