
var lineReader = require('line-reader');

var printnext = false;
lineReader.eachLine('./parallel_test_dgp2', function(line, last) {
  if (printnext === true) {
    if (typeof line.split(' ')[5] === 'string'){
      if(~line.split(' ')[5].indexOf('0')) {
        console.log(line.split(' ')[2]);
        printnext = false;
      }
    }
  }

  if (!~line.indexOf('TIME')) {
     printnext = true;
     return;
  }

});