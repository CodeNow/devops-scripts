'use strict'
const Promise = require('bluebird')
const joi = require('joi')

const Ponos = require('ponos')
const execFile = require('child_process').execFile

function deployWorker (job) {
  return Promise.fromCallback((cb) => {
    const version = job.version
    const env = job.env
    const service = job.service

    execFile('/bin/bash', [`ansible-playbook -i ./${env}-hosts --vault-password-file /.vaultpass -e git_branch=v${version} /ansible/${service}.yml -t deploy`], (error, stdout, stderr) => {
      if (error) { return cb(error) }
      console.log(stdout, stderr)
    })
  })
}

const server = new Ponos.Server({
  events: {
    'deploy.requested': {
      task: deployWorker,
      jobSchema: joi.object({
        version: joi.string().required(),
        env: joi.string().required(),
        service: joi.string().required()
      }).required()
    }
  }
})
server.start()
  .then(() => { console.log('server started') })
  .catch((err) => { console.error('server error:', err.stack || err.message || err) })
