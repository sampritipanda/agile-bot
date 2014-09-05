# Description:
#   Posts Hangouts Notifications from AgileVentures to Slack.
#
# Dependencies:
#   "requestify": "*"
#
# Configuration:
#
# Commands:
#   post hangout title, link and type to /hubot/hangouts-notify
#
# Author:
#   sampritipanda

CHANNELS = {
  "autograder"  : "C02AA47UK"
  "betasaas"    : "C02AHEA5P"
  "codealia"    : "C0297TUQC"
  "codelia"     : "C0297TUQC"
  "community portal": "C02HVF1TP"
  "communityportal": "C02HVF1TP"
  "comport"     : "C02HVF1TP"
  "educhat"     : "C02AD0LG0"
  "edu chat"    : "C02AD0LG0"
  "esaas"       : "C02A6835V"
  "cs169"       : "C02A6835V"
  "mooc"        : "C02A6835V"
  "localsupport": "C02A6UWBJ"
  "osra"        : "C02AAM8SY"
  "websiteone"  : "C029E8G80"
  "wso"         : "C029E8G80"
  "general"     : "C0285CSUF"
  "pairing_notifications" : "C02BNVCM1"
  "scrum_notifications" : "C02B4QH1C"
}

requestify = require('requestify')

module.exports = (robot) ->

  find_project_for_hangout = (name) ->
    return id for own trigger, id of CHANNELS when name.match(new RegExp(trigger))

  send_message = (channel, message, user) ->
    requestify.post 'https://slack.com/api/chat.postMessage',
      channel: channel
      text: message
      username: user.name
      icon_url: user.avatar
      parse: full
      token: process.env.SLACK_API_TOKEN


  robot.router.post "/hubot/hangouts-notify", (req, res) ->
    # Parameters from the post request are:
    # title=HangoutTitle
    # link=https://plus.google.com/hangouts/_/56465464567fdsg45654yg
    # type = "Scrum" / "PairProgramming"
    # host_name = Random Guy
    # host_avatar = https://www.gravatar.com/avatar/fsd87fgds87f4387

    user = name: req.body.host_name, avatar: req.body.host_avatar
    send_message CHANNELS.general, "#{req.body.title}: #{req.body.link}", user

    if req.body.type == "Scrum"
      send_message CHANNELS.scrum_notifications, "@channel #{req.body.title}: #{req.body.link}", user
    else if req.body.type == "PairProgramming"
      room = find_project_for_hangout(req.body.title.toLowerCase())
      send_message CHANNELS.pairing_notifications, "@channel #{req.body.title}: #{req.body.link}", user
      send_message room, "#{req.body.title}: #{req.body.link}", user


    # Send back an empty response
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()
