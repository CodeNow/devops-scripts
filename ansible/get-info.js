var AWS_ACCESS_KEY = process.env.AWS_ACCESS_KEY
var AWS_SECRET_KEY = process.env.AWS_SECRET_KEY
var ENVIRONMENT = process.env.ENVIRONMENT

var assign = require('101/assign')
var AWS = require('aws-sdk')
var Dockerode = require('dockerode')
var find = require('101/find')
var fs = require('fs')
var join = require('path').join
var Promise = require('bluebird')
var Swarmerode = require('swarmerode')

AWS.config.update({
  accessKeyId: AWS_ACCESS_KEY,
  secretAccessKey: AWS_SECRET_KEY,
  region: 'us-west-2'
})
var ec2 = new AWS.EC2()
var cloudwatch = new AWS.CloudWatch()

function promiseWhile (condition, action) {
  function loop (data) {
    if (condition(data)) { return Promise.resolve(data) }
    return action(data).then(loop)
  }
  return loop
}

Dockerode = Swarmerode(Dockerode)

var certs = {}
try {
  // DOCKER_CERT_PATH is docker's default thing it checks - may as well use it
  var certPath = process.env.DOCKER_CERT_PATH
  certs.ca = fs.readFileSync(join(certPath, '/ca.pem'))
  certs.cert = fs.readFileSync(join(certPath, '/cert.pem'))
  certs.key = fs.readFileSync(join(certPath, '/key.pem'))
} catch (e) {
  console.error({ err: e }, 'cannot load certificates for docker!!')
  // use all or none - so reset certs here
  certs = {}
}

var docker = new Dockerode(assign({
  host: process.env.SWARM_HOSTNAME,
  port: process.env.SWARM_PORT,
  timeout: 2 * 60 * 1000
}, certs))

var UNITS = {
  'B': 'Bytes',
  'KiB': 'Kilobytes',
  'MiB': 'Megabytes',
  'GiB': 'Gigabytes'
}

var FACTOR = {
  Bytes: 1000 * 1000 * 1000,
  Kilobytes: 1000 * 1000,
  Megabytes: 1000,
  Gigabytes: 1
}

var FILTER_PARAMS = {
  Filters: [
    { Name: 'tag:role', Values: ['dock'] },
    {
      Name: 'instance.group-name',
      Values: [ `${ENVIRONMENT}-dock` ]
    }
  ]
}

Promise.props({
  docks: getDocks(),
  swarmHosts: getSwarmInfo()
})
  .then(function (data) {
    return Promise.each(data.swarmHosts, function (h) {
      var d = find(data.docks, function (dock) {
        return dock.PrivateIpAddress === h.Host
      })
      if (!d) {
        console.error('could not find match:', h.host)
        return
      }
      var org = find(d.Tags, function (t) { return t.Key === 'org' })
      if (!org) {
        console.error('could not find org tag')
        return
      }
      var orgID = org.Value
      var postData = {
        Namespace: 'Runnable/Swarm',
        MetricData: [
          {
            MetricName: 'Swarm Reserved Memory',
            Dimensions: [{
              Name: 'InstanceId',
              Value: d.InstanceId
            }, {
              Name: 'AutoScalingGroupName',
              Value: `asg-production-${ENVIRONMENT}-${orgID}`
            }],
            Value: h.Value,
            Unit: h.Unit
          }, {
            MetricName: 'Swarm Reserved Memory',
            Dimensions: [{
              Name: 'AutoScalingGroupName',
              Value: `asg-production-${ENVIRONMENT}-${orgID}`
            }],
            Value: h.Value,
            Unit: h.Unit
          }
        ]
      }
      console.log(JSON.stringify(postData))
      return Promise.fromCallback(function (cb) {
        cloudwatch.putMetricData(postData, cb)
      })
        .then(function () { console.log('posted') })
    })
  })
  .catch(function (err) {
    console.error('ERROR:', err.stack || err.message || err)
  })

function getDocks () {
  return Promise.resolve({ instances: [] })
    .then(promiseWhile(
      function (data) { return data.done },
      function (data) {
        const opts = assign({}, FILTER_PARAMS)
        if (data.NextToken) { opts.NextToken = data.NextToken }
        return Promise.fromCallback(function (cb) {
          ec2.describeInstances(opts, cb)
        })
          .then(function (awsData) {
            awsData.Reservations.forEach(function (r) {
              r.Instances.forEach(function (i) {
                data.instances.push(i)
              })
            })
            data.NextToken = awsData.NextToken
            data.done = !awsData.NextToken
            return data
          })
      }
    ))
    .then(function (data) { return data.instances })
}

function getSwarmInfo () {
  return Promise.fromCallback(function (cb) {
    docker.swarmInfo(cb)
  })
    .then(function (info) {
      return Object.keys(info.parsedSystemStatus.ParsedNodes).map(function (key) {
        var node = info.parsedSystemStatus.ParsedNodes[key]
        var usedMemory = node.ReservedMem.split('/').shift().trim()
        var availableMemory = node.ReservedMem.split('/').pop().trim()
        var usedMemoryValue = parseFloat(usedMemory.split(' ').shift())
        var usedMemoryUnits = UNITS[usedMemory.split(' ').pop()]
        var availableMemoryValue = parseFloat(availableMemory.split(' ').shift())
        var availableMemoryUnits = UNITS[availableMemory.split(' ').pop()]

        var usedMemoryGiB = usedMemoryValue / FACTOR[usedMemoryUnits]
        var availableMemoryGiB = availableMemoryValue / FACTOR[availableMemoryUnits]

        var percentage = (usedMemoryGiB / availableMemoryGiB) * 100

        return {
          Host: node.Host.split(':').shift(),
          Value: percentage,
          Unit: 'Percent'
        }
      })
  })
}
