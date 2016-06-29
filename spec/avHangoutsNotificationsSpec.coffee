avHangoutsNotifications = require('../scripts/av-hangouts-notifications.coffee')
describe 'AV Hangout Notifications', ->
  beforeEach ->
    routes_functions = {}
    avHangoutsNotifications({router: { post: (s,f) -> routes_functions[s] = f } })
    @routes_functions = routes_functions

  it 'has appropriate routes', ->
    expect(typeof @routes_functions['/hubot/hangouts-notify']).toBe("function")
    expect(typeof @routes_functions['/hubot/hangouts-video-notify']).toBe("function")

  it 'directs scrum video notifications to slack general channel', ->
    res = {}
    res.writeHead = -> {}
    res.end = -> {} 
    req = { body: { host_name: 'jon', host_avatar: 'jon.jpg', type: 'Scrum' } }
    req.post = -> {}
    spyOn(req, 'post')
    @routes_functions['/hubot/hangouts-video-notify'](req,res)
    expect(req.post).toHaveBeenCalled()
