# Description:
#   Posts Hangouts Notifications from AgileVentures to Slack and Gitter.
#
# Dependencies:
#   "requestify": "*"
#
# Configuration:
#
# Commands:
#   post hangout title, link and type to /hubot/hangouts-notify
#   post hangout title, video_lin and type to /hubot/hangouts-video-notify
#
# Author:
#   sampritipanda


[CHANNELS, GITTER_ROOMS] = require('./../config/' + process.env.LIVE_ENV + '.coffee')

request = require('request')
rollbar = require('rollbar')

rollbar.init(process.env.ROLLBAR_ACCESS_TOKEN, {enabled: process.env.ENABLE_ROLLBAR != 'false'})

module.exports = (robot) ->
  find_project_for_hangout = (name) ->
    return id for own trigger, id of CHANNELS when name.match(new RegExp(trigger))

  send_gitter_message_avoid_repeats = (channel, message) ->
    request.get "https://api.gitter.im/v1/rooms/#{GITTER_ROOMS['saasbook/AV102']}/chatMessages",
      auth:
        bearer: process.env.GITTER_API_TOKEN
    , (error, response, body) ->
      payload = JSON.parse body
      matches = payload.filter (m) -> m['text'] == message
      if matches.length == 0
        send_gitter_message(channel, message)

  send_gitter_message = (channel, message) ->
    request.post "https://api.gitter.im/v1/rooms/#{GITTER_ROOMS['AgileVentures/agile-bot']}/chatMessages",
      form:
        text: message
      auth:
        bearer: process.env.GITTER_API_TOKEN
    , (error, response, body) ->
      payload = JSON.parse body
      if payload['error']
        rollbar.reportMessageWithPayloadData payload['error'],
          origin: 'send_gitter_message'
          level: 'error'
          custom:
            error: error
            response: response
            body: body

  send_slack_message = (channel, message, user) ->
    request.post 'https://slack.com/api/chat.postMessage', form:
      channel: channel
      text: message
      username: user.name
      icon_url: user.avatar
      parse: 'full'
      token: process.env.SLACK_API_TOKEN
    , (error, response, body) ->
      try payload = JSON.parse body
      catch e then payload = {}
      unless payload['ok']
        rollbar.reportMessageWithPayloadData payload['error'],
          origin: 'send_slack_message'
          level: 'error'
          custom:
            error: error
            response: response
            body: body

  robot.router.post "/hubot/hangouts-notify", (req, res) ->
# Parameters from the post request are:
# title=HangoutTitle
# link=https://plus.google.com/hangouts/_/56465464567fdsg45654yg
# type = "Scrum" / "PairProgramming"
# host_name = Random Guy
# host_avatar = https://www.gravatar.com/avatar/fsd87fgds87f4387
    user = name: req.body.host_name, avatar: req.body.host_avatar

    if req.body.type == "Scrum"
      send_slack_message CHANNELS.general, "@here #{req.body.title}: #{req.body.link}", user
      send_slack_message CHANNELS.standup_notifications, "@channel #{req.body.title}: #{req.body.link}", user
    else if req.body.type == "PairProgramming"
      room = find_project_for_hangout(req.body.project)

      if room == CHANNELS.cs169
        send_gitter_message_avoid_repeats room, "[#{req.body.title} with #{user.name}](#{req.body.link}) is starting NOW!"
      else
        send_slack_message CHANNELS.general, "#{req.body.title}: #{req.body.link}", user

        send_slack_message CHANNELS.pairing_notifications, "@channel #{req.body.title}: #{req.body.link}", user
        send_slack_message room, "@here #{req.body.title}: #{req.body.link}", user


    # Send back an empty response
    res.writeHead 204, {'Content-Length': 0}
    res.end()

  robot.router.post "/hubot/hangouts-video-notify", (req, res) ->
# Parameters from the post request are:
# title=HangoutTitle
# video=http://youtu.be/CLoDNn9FNlY
# type = "Scrum" / "PairProgramming"
# host_name = Random Guy
# host_avatar = https://www.gravatar.com/avatar/fsd87fgds87f4387
    user = name: req.body.host_name, avatar: req.body.host_avatar

    if req.body.type == "Scrum"
      send_slack_message CHANNELS.general, "Video/Livestream for #{req.body.title}: #{req.body.video}", user
    else if req.body.type == "PairProgramming"
      room = find_project_for_hangout(req.body.project)
      unless room == CHANNELS.cs169
        send_slack_message CHANNELS.general, "Video/Livestream for #{req.body.title}: #{req.body.video}", user
        send_slack_message room, "Video/Livestream for #{req.body.title}: #{req.body.video}", user

    # Send back an empty response
    res.writeHead 204, {'Content-Length': 0}
    res.end()
