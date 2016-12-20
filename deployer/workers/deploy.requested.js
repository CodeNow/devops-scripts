'use strict'
require('loadenv')()
const joi = require('joi')
const Promise = require('bluebird')
const spawn = require('child_process').spawn

const logger = require('../logger')
const ansibleRoot = process.env.ANSIBLE_DIR
const secretRoot = process.env.SECRET_DIR

module.exports.jobSchema = joi.object({
  version: joi.string().required(),
  env: joi.string().required(),
  service: joi.string().required()
}).required()

module.exports.task = (job) => {
  const log = logger.child({ job, worker: 'deploy.requested' })

  return Promise.fromCallback((cb) => {
    const version = job.version
    const env = job.env
    const service = job.service

    const commandArgs = [
      '-i', `${env}-hosts`,
      `--vault-password-file=${secretRoot}/vault-pass`,
      '-e', `git_branch=${version}`,
      '-t', 'deploy',
      `${service}.yml`
    ]

    const spawnOpts = {
      cwd: ansibleRoot,
      env: {
        SSH_AUTH_SOCK: process.env.SSH_AUTH_SOCK,
        SSH_AGENT_PID: process.env.SSH_AGENT_PID
      }
    }

    log.trace({
      commandArgs,
      spawnOpts
    }, `about to call ${process.env.ANSIBLE_BIN}`)

    const cmd = spawn(process.env.ANSIBLE_BIN, commandArgs, spawnOpts)

    cmd.stdout.on('data', (data) => {
      log.trace({ type: 'stdout' }, data.toString())
    })

    cmd.stderr.on('data', (data) => {
      log.error({ type: 'stderr' }, data.toString())
    })

    cmd.on('close', (code) => {
      log.trace(`ansible-playbook exited with code ${code}`)
      cb()
    })

    cmd.on('error', (err) => {
      log.error({ err }, 'Failed to start ansible-playbook process.')
      cb(err)
    })
  })
}
