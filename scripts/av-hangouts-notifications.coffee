# Description:
#   Posts Hangouts Notifications from AgileVentures to Slack.
# 
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   post hangout title and link to /hubot/hangouts-notify
#
# Author:
#   sampritipanda

CHANNELS = {
  "autograder"  : "C02AA47UK"
  "betasaas"    : "C02AHEA5P"
  "codealia"    : "C0297TUQC"
  "codelia"     : "C0297TUQC"
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

module.exports = (robot) ->

  find_project_for_hangout = (name) ->
    return id for own trigger, id of CHANNELS when name.match(new RegExp(trigger))

  robot.router.post "/hubot/hangouts-notify", (req, res) ->
    rooms = [CHANNELS.general]
    rooms.push(CHANNELS.pairing_notifications, find_project_for_hangout(req.body.title.toLowerCase())) if req.body.type == "PairProgramming"
    rooms.push(CHANNELS.scrum_notifications) if req.body.type == "Scrum"

    # Parameters from the post request are:
    # title=HangoutTitle
    # link=https://plus.google.com/hangouts/_/56465464567fdsg45654yg
    # type = "Scrum" / "PairProgramming"

    (robot.messageRoom room, "#{req.body.title}: #{req.body.link}") for room in rooms

    # Send back an empty response
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()
