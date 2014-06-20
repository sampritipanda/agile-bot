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
    room = "C0285CSUF" #req.params.room

    # Parameters from the post are:
    # title=HangoutTitle
    # link=https://plus.google.com/hangouts/_/56465464567fdsg45654yg
    #
    robot.messageRoom room, "#{req.body.title}: #{req.body.link}"

    # Send back an empty response
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()
