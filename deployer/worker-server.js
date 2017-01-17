'use strict'
require('loadenv')()
const Ponos = require('ponos')
const log = require('./logger')

module.exports = new Ponos.Server({
  name: process.env.APP_NAME,
  enableErrorEvents: true,
  log: log,
  rabbitmq: {
    channel: {
      prefetch: process.env.WORKER_PREFETCH
    },
    hostname: process.env.RABBITMQ_HOSTNAME,
    port: process.env.RABBITMQ_PORT,
    username: process.env.RABBITMQ_USERNAME,
    password: process.env.RABBITMQ_PASSWORD
  },
  events: {
    'deploy.requested': require('./workers/deploy.requested')
  }
})
