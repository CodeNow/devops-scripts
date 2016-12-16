'use strict'
require('loadenv')()

const log = require('./logger')
const server = require('./worker-server')

server.start()
.then(() => {
  log.trace('server started')
})
.catch((err) => {
  log.error({ err }, 'server error:')
  throw err
})
