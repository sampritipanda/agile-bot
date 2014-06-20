# Description:
#   Posts Hangouts Notifications from AgileVentures to Slack General Room.
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

module.exports = (robot) ->
  robot.router.post "/hubot/hangouts-notify", (req, res) ->
    # Setting the channel to general temporarily
    rooms = ["C0285CSUF"] #req.params.room
    rooms.push("C02BNVCM1") if req.body.type == "PairProgramming"
    rooms.push("C02B4QH1C") if req.body.type == "Scrum"
    # Parameters from the post are:
    # title=HangoutTitle
    # link=https://plus.google.com/hangouts/_/56465464567fdsg45654yg
    # type = "Scrum" / "PairProgramming"
    (robot.messageRoom room, "#{req.body.title}: #{req.body.link}") for room in rooms

    # Send back an empty response
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()
