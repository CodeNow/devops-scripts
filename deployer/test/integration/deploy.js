'use strict'
const Code = require('code')
const Lab = require('lab')
const Promise = require('bluebird')
const Publisher = require('ponos/lib/rabbitmq')

const lab = exports.lab = Lab.script()
const app = require('../../index')
const workerServer = require('../../worker-server')

const after = lab.after
const afterEach = lab.afterEach
const before = lab.before
const beforeEach = lab.beforeEach
const describe = lab.describe
const expect = Code.expect
const it = lab.it

const publisher = new Publisher({
  name: process.env.APP_NAME,
  hostname: process.env.RABBITMQ_HOSTNAME,
  port: process.env.RABBITMQ_PORT,
  username: process.env.RABBITMQ_USERNAME,
  password: process.env.RABBITMQ_PASSWORD,
  events: ['deploy.requested']
})

describe('deploy test', () => {
  beforeEach((done) => {
    publisher.connect()
    .then(() => {
      return app.start()
    })
    .asCallback(done)
  })

  afterEach((done) => {
    publisher.disconnect()
    .then(() => {
      return workerServer.disconnect()
    }).asCallback(done)
    done()
  })

  it('should run deploy', (done) => {
    publisher.publishEvent('deploy.requested', {
      version: 'master',
      env: 'gamma',
      service: 'deployer'
    })
    done()
  })
})
