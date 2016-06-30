nock = require('nock');

slack = nock('https://slack.com:444')
                .post('/api/chat.postMessage')
                .reply(200, {
                  ok: false,
                  error: 'not_authed'
                 });

avHangoutsNotifications = require('../scripts/av-hangouts-notifications.coffee')

describe 'AV Hangout Notifications', ->
  beforeEach ->
    routes_functions = {}
    avHangoutsNotifications({router: { post: (s,f) -> routes_functions[s] = f } })
    @routes_functions = routes_functions

  # it 'has appropriate routes', ->
  #   expect(typeof @routes_functions['/hubot/hangouts-notify']).toBe("function")
  #   expect(typeof @routes_functions['/hubot/hangouts-video-notify']).toBe("function")

  describe 'hangouts-video-notify', ->

    beforeEach (done)->
      setTimeout((->
        res = {}
        res.writeHead = -> {}
        res.end = -> {} 
        req = { body: { host_name: 'jon', host_avatar: 'jon.jpg', type: 'Scrum' } }
        req.post = -> {}   
        @routes_functions['/hubot/hangouts-video-notify'](req,res)
        done()
      ), 5000)

    it 'directs scrum video notifications to slack general channel', (done)->
      expect(slack.isDone()).toBe(true)
      done()

