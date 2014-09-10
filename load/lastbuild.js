
var lineReader = require('line-reader');
var print = '';
lineReader.eachLine('./parallel_test_dmag', function(line, last) {
  if (typeof line.split(' ')[5] === 'string'){
    if(~line.split(' ')[5].indexOf('0')) {
      print = line.split(' ')[2];
    }
  }

  if (!~line.indexOf('TIME')) {
     console.log(print);
  }

});