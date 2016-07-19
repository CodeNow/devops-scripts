'use strict'
const https = require('https')

exports.handler = function (event, context) {
  let message
  try {
    message = JSON.parse(event.Records[0].Sns.Message)
  } catch (e) {
    message = { Description: event.Records[0].Sns.Message }
  }

  const postData = {
    channel: '#aws-notifications',
    username: 'AWS',
    text: '*' + event.Records[0].Sns.Subject + '*',
    icon_emoji: ':cloud:'
  }

  let slackMessage = [
    message.Description,
    '',
    message.Cause
  ].join('\n')

  if (!message.Description && !message.Cause) {
    slackMessage = 'test notification :partyparrot:'
  }

  postData.attachments = [{
    color: 'good',
    text: slackMessage
  }]

  const options = {
    method: 'POST',
    hostname: 'hooks.slack.com',
    port: 443,
    path: '/services/T029DEC10/B141U5BHT/UaAwljeWydJaiW6RmD09C4Wx'
  }

  const req = https.request(options, (res) => {
    res.setEncoding('utf8')
    res.on('data', () => {})
    res.on('end', () => { context.done(null) })
  })

  req.on('error', (e) => {
    console.error('problem with request: ' + e.message)
  })

  req.write(JSON.stringify(postData))
  req.end()
}
