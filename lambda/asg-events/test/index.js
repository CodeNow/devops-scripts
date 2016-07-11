const https = require('https')
const EventEmitter = require('events')

class MockRequest extends EventEmitter {
  constructor () {
    super()
    this._written_data = []
  }

  write (data) {
    this._written_data.push(data)
  }

  end () {
    this._ended = true
  }
}

class MockResponse extends EventEmitter {
  setEncoding (encoding) {
    this.encoding = encoding
  }
}

const test = require('ava')
const sinon = require('sinon')
const NEW_EC2_INSTANCE = require('./fixtures/new-ec2-instances.json')
const TEST_NOTIFICATION = require('./fixtures/test-notification.json')

const handler = require('../').handler

test.before((t) => {
  sinon.stub(https, 'request')
})

test.beforeEach((t) => {
  https.request.reset()
})

test.cb('it should call done in the context', (t) => {
  const request = new MockRequest()
  const response = new MockResponse()
  https.request.returns(request)
  https.request.yieldsAsync(response)
  sinon.stub(request, 'end', () => {
    setTimeout(() => { response.emit('end') })
  })
  handler(NEW_EC2_INSTANCE, {
    done: () => {
      t.pass()
      t.end()
    }
  })
})

test.cb('it should post to slack', (t) => {
  const request = new MockRequest()
  const response = new MockResponse()
  https.request.returns(request)
  https.request.yieldsAsync(response)
  sinon.stub(request, 'end', () => {
    setTimeout(() => { response.emit('end') })
  })
  handler(NEW_EC2_INSTANCE, { done: () => {
    sinon.assert.calledOnce(https.request)
    sinon.assert.calledWithExactly(
      https.request,
      {
        method: 'POST',
        hostname: 'hooks.slack.com',
        port: 443,
        path: sinon.match(/\/services\/[^\/]+\/[^\/]+\/[^\/]+/)
      },
      sinon.match.func
    )
    t.end()
  } })
})

test.cb('it should send the description and cause', (t) => {
  const request = new MockRequest()
  const response = new MockResponse()
  https.request.returns(request)
  https.request.yieldsAsync(response)
  sinon.stub(request, 'end', () => {
    setTimeout(() => { response.emit('end') })
  })
  handler(NEW_EC2_INSTANCE, { done: () => {
    t.is(request._written_data.length, 1, 'one write')
    const s = JSON.parse(request._written_data.pop())
    t.regex(s.attachments[0].text, /Launching a new EC2 instance/)
    t.end()
  } })
})

test.cb('it should send a test message', (t) => {
  const request = new MockRequest()
  const response = new MockResponse()
  https.request.returns(request)
  https.request.yieldsAsync(response)
  sinon.stub(request, 'end', () => {
    setTimeout(() => { response.emit('end') })
  })
  handler(TEST_NOTIFICATION, { done: () => {
    t.is(request._written_data.length, 1, 'one write')
    const s = JSON.parse(request._written_data.pop())
    t.regex(s.attachments[0].text, /test notification :partyparrot:/)
    t.end()
  } })
})
