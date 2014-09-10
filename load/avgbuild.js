var lineReader = require('line-reader');
var numz = [];
lineReader.eachLine(process.argv[2], function(line, last) {
  if (typeof line.split(' ')[5] === 'string'){
    numz.push(parseInt(line.split(' ')[2], 10));
  }

  if (!~line.indexOf('TIME')) {
    var sum = 0;
    for(var i = 0; i < numz.length; i++){
        sum += numz[i]; //don't forget to add the base
    }
    var avg = sum/numz.length;
    console.log(avg);
    numz = [];
  }

});