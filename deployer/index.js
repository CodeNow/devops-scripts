'use strict'
const joi = require('joi')
const Promise = require('bluebird')

const Ponos = require('ponos')
const spawn = require('child_process').spawn

function deployWorker (job) {
  return Promise.fromCallback((cb) => {
    const version = job.version
    const env = job.env
    const service = job.service

    const cmd = spawn('ansible-playbook', [
      '-i', `/ansible/${env}-hosts`,
      '--vault-password-file=/root/.ssh/vault-pass',
      '-e', `git_branch=${version}`,
      '-t', 'deploy',
      `/ansible/${service}.yml`
    ], {
      cwd: '/ansible'
    })

    cmd.stdout.on('data', (data) => {
      console.log(`stdout: ${data}`)
    })
    cmd.stderr.on('data', (data) => {
      console.log(`stderr: ${data}`)
    })
    cmd.on('close', (code) => {
      console.log(`child process exited with code ${code}`)
      cb()
    })
    cmd.on('error', (err) => {
      console.log('Failed to start child process.', err)
      cb(err)
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
.then(() => {
  console.log('server started')
})
.catch((err) => {
  console.error('server error:', err)
  throw err
})
