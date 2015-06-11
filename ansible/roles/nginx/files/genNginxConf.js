var fs = require('fs');
var xml2js = require('xml2js');
var request = require('request');
var exists = require('101/exists');
var async = require('async');
var parser = new xml2js.Parser();

var paths = {
  'login': true,
  'signup': true,
  'jobs': true,
  'about': true,
  'privacy': true
};

async.waterfall([
  nginxWebServicesRewrite,
  nginxConfigHeader,
  nginxManualLocations,
  fs.readFile.bind(fs, 'sitemap.xml'),
  parser.parseString.bind(parser),
  function (result, cb) {
    result.urlset.url.forEach(function (o) {
      var path = o.loc[0].replace('http://runnable.com/', '');
      if (path.indexOf('/') !== -1) {
        path = path.split('/').shift();
      }
      // escape "
      path = path.replace(/"/g, '\\"');
      // drop any including $ (messes w/ nginx)
      if (path.indexOf('$') !== -1) { return; }
      // drop ones where path now is undefined
      if (!exists(path) || path.length === 0) { return; }
      // monthly are our manual pages
      if (o.changefreq[0] === 'monthly') { return; }
      // keep track of dupes
      if (paths[path]) { return; }
      else { paths[path] = true; }
      if (o.changefreq[0] === 'daily') {
        if (o.priority[0] === '0.5') {
          console.log('# CHANNEL:', path);
          locationEqualsDirective(path);
        }
      }
      else if (o.changefreq[0] === 'weekly') {
        if (o.priority[0] === '0.6') {
          console.log('# EXAMPLE:', path);
          locationRegexDirective(path);
        }
      }
    });
    cb();
  },
  nginxConfigFooter
], function (err) {
  if (err) {
    console.error('error:', err);
    return process.exit(1);
  }
  process.exit(0);
});

function nginxWebServicesRewrite (cb) {
  console.log([
    'server {',
    '\tserver_name ~^web-(?<token>.+)\.runnable.com$;',
    '\tlocation = / {',
    '\t\treturn 301 "$scheme://web-$token.runnablecodesnippets.com$request_uri";',
    '\t}',
    '}',
    'server {',
    '\t server_name ~^services-(?<token>.+)\.runnable.com$;',
    '\tlocation = / {',
    '\t\treturn 301 "$scheme://services-$token.runnablecodesnippets.com$request_uri";',
    '\t}',
    '}',
    ''
  ].join('\n'));
  cb();
}

function nginxConfigHeader (cb) {
  console.log([
    'server {',
    '\tserver_name runnable.com;'
  ].join('\n'));
  cb();
}

function nginxManualLocations (cb) {
  console.log([
    '### Directives we do not want to move to sandbox app yet',
    'location = / {',
    '\treturn 302 $scheme://runnable.io;',
    '}',
    'location = /login {',
    '\treturn 302 $scheme://code.runnable.com/login;',
    '}',
    'location = /signup {',
    '\treturn 302 $scheme://code.runnable.com/signup;',
    '}',
    'location = /about {',
    '\treturn 302 $scheme://code.runnable.com/about;',
    '}',
    'location = /jobs {',
    '\treturn 302 $scheme://code.runnable.com/jobs;',
    '}',
    'location = /privacy {',
    '\treturn 302 $scheme://code.runnable.com/privacy;',
    '}',
  ].join('\n'));
  cb();
}

function nginxConfigFooter (cb) {
  console.log([
    '} # !server',
  ].join('\n'));
  cb();
}

function locationEqualsDirective (path) {
  var quote = (path.indexOf(' ') !== -1) ? '"' : '';
  console.log([
    '\tlocation = ' + quote + '/' + path + quote + ' {',
    '\t\treturn 301 ' + quote + '$scheme://code.runnable.com/' + path + quote + ';',
    '\t}'
  ].join('\n'));
}

function locationRegexDirective (path) {
  // these won't need any quotes to escape
  console.log([
    '\tlocation ~ ^\\/' + path + '(\\/.+)?$ {',
    '\t\treturn 301 $scheme://code.runnable.com/' + path + '$1;',
    '\t}'
  ].join('\n'));
}
