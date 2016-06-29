avHangoutsNotifications = require('../scripts/av-hangouts-notifications.coffee')
describe 'AV Hangout Notifications', ->
  it 'has appropriate routes', ->
    routes_functions = []
    avHangoutsNotifications({router: {post: (s,f)-> routes_functions.push [s,f]}})
    expect(routes_functions[0][0]).toEqual('/hubot/hangouts-notify')
    expect(routes_functions[1][0]).toEqual('/hubot/hangouts-video-notify')