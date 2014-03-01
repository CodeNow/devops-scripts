var Docker = require('dockerode');
var docker = new Docker({socketPath: '/var/run/docker.sock'});
var async = require('async');

var failed = [];
var repos = [ 'registry.runnable.com/runnable/UwNBFqKKDKA1AACj',
  'registry.runnable.com/runnable/27b3e370-6b87-41e0-aa55-e5eb61f0ffa9',
  'registry.runnable.com/runnable/Uv_mgVty7Z0OAABs',
  'registry.runnable.com/runnable/Uv_f4q5O82QOAAAN',
  'registry.runnable.com/runnable/6df32b86-0419-4bf4-ac95-990abbaed629',
  'registry.runnable.com/runnable/Uv_nWFty7Z0OAACE',
  'registry.runnable.com/runnable/b2fbcfcb-5747-4a1d-976b-7dd05861eda6',
  'registry.runnable.com/runnable/Uv_av15p2NwNAADA',
  'registry.runnable.com/runnable/52210954-415f-416f-9cdf-2db4ace060f9',
  'registry.runnable.com/runnable/07d071e1-84db-4908-a649-0a96e681bc6c',
  'registry.runnable.com/runnable/97adcd69-5157-4ba3-bf99-e09bc9a85482',
  'registry.runnable.com/runnable/Uv7T6asadUICAAAf',
  'registry.runnable.com/runnable/cad34bc6-5022-44fb-bd00-fd65a35cdcf7',
  'registry.runnable.com/runnable/Uv7TivKpIPwBAACl',
  'registry.runnable.com/runnable/05e9c40d-ad69-460b-8f8a-333be043ee21',
  'registry.runnable.com/runnable/b0648a28-3fb9-4167-a5d6-b823cbf22190',
  'registry.runnable.com/runnable/Uv2Kk4qaaQ9xAACw',
  'registry.runnable.com/runnable/UvvLeisQJ0FbAABK',
  'registry.runnable.com/runnable/UvvJLGBhaDRbAABa',
  'registry.runnable.com/runnable/cbff3237-dbe5-402f-ba6e-5267e55427c4',
  'registry.runnable.com/runnable/Uv0pM1ay8nVrAAE2',
  'registry.runnable.com/runnable/ce4e4908-a52c-46d2-a80d-78119b1e7569',
  'registry.runnable.com/runnable/Uvh3bPQPfyEfAABk',
  'registry.runnable.com/runnable/06aad1fd-0955-4eaa-864f-2b28ceaacd7d',
  'registry.runnable.com/runnable/5256d2d6-e786-4177-9f0a-83d9320d28ad',
  'registry.runnable.com/runnable/Uve48omYcg4TAABY',
  'registry.runnable.com/runnable/7bb550a7-8687-497c-8ec0-ecffe4299b64',
  'registry.runnable.com/runnable/4172e45b-5c02-4923-9e89-a50577e30e4d',
  'registry.runnable.com/runnable/UvUP_XuS8xdsAABg',
  'registry.runnable.com/runnable/UvURK7ZFlVBsAAAL',
  'registry.runnable.com/runnable/8d37ee5f-8152-4aba-ae36-4215dc2a60ec',
  'registry.runnable.com/runnable/UvSRLoTgdONjAAAn',
  'registry.runnable.com/runnable/04a59eda-d57e-4d50-9ace-44b295447262',
  'registry.runnable.com/runnable/d13e0350-e885-4fec-a3a4-3ef5a28a43e5',
  'registry.runnable.com/runnable/23fb9006-1e48-4a8d-b75b-7ce46a229100',
  'registry.runnable.com/runnable/dba29350-35b8-4bd2-bd34-4e2654df3f97',
  'registry.runnable.com/runnable/UvSQe-YuzN1jAAAY',
  'registry.runnable.com/runnable/a70e71ba-7e87-4912-8a31-d7d9618e00ca',
  'registry.runnable.com/runnable/b64b23e7-0017-4b99-b573-b791fdb6ef6e',
  'registry.runnable.com/runnable/UvSKMx_c5IBjAABP',
  'registry.runnable.com/runnable/c52a9ad5-a02f-4978-a2f1-d6a5ecfaec2d',
  'registry.runnable.com/runnable/c6c9646e-7e5c-4dba-95b9-b3b3ef72b614',
  'registry.runnable.com/runnable/UozsbUlX6jcgAABh',
  'registry.runnable.com/runnable/82e50255-38ca-4440-8f0d-2ebd8608a5d5' ];

async.eachLimit(repos, 3, function (repo, cb) {
  process.stdout.write('.');
  var image = docker.getImage(repo);
  image.push({}, function (err, stream) {
    if (err) {
      failed.push(repo);
      cb();
    } else {
      stream.on('data', function (raw) {
        var data = JSON.parse(raw);
        if (data.error) {
          console.log(data);
          failed.push(repo);
        }
      });
      stream.on('error', function (err) {
        failed.push(repo);
        cb();
      });
      stream.on('end', cb);
    }
  });
}, function (err) {
  if (err) {
    throw err;
  } else {
    console.log('DONE');
    console.log(failed);
    process.exit();
  }
});