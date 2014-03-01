var s3sync = require('s3-sync');
var readdirp = require('readdirp');
var through = require('through');

readdirp({ root: '/prod/images' })
  .pipe(through(function (entry) {
    this.push({
      src: entry.fullPath,
      dest: entry.fullPath.replace('/prod/', '')
    });
  }))
  .pipe(s3sync({
    key: 'AKIAJA3VH6N377FCXOAQ',
    secret: '1u3sPGgzIVJcDNI7uNYVmDzhiPRUQewnn9ke2+qL',
    bucket: 'runnableimages',
    concurrency: 16
  }))
  .on('data', function(file) {
    console.log(file.fullPath + ' -> ' + file.url);
  });