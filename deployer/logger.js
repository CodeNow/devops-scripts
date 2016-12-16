'use strict'
require('loadenv')()
const bunyan = require('bunyan')
const cls = require('continuation-local-storage')

const serializers = {
  tx: () => {
    let out
    try {
      out = {
        tid: cls.getNamespace('ponos').get('tid')
      }
    } catch (e) {
      // cant do anything here
    }
    return out
  }
}

const logger = bunyan.createLogger({
  name: process.env.APP_NAME,
  streams: [
    {
      level: process.env.LOG_LEVEL,
      stream: process.stdout
    }
  ],
  serializers: module.exports.serializers,
  src: true,
  branch: process.env._VERSION_GIT_COMMIT,
  commit: process.env._VERSION_GIT_BRANCH,
  environment: process.env.NODE_ENV
})

module.exports = logger.child({ tx: true })

module.exports.serializers = serializers
