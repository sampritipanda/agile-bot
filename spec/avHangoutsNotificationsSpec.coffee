nock = require('nock');

avHangoutsNotifications = require('../scripts/av-hangouts-notifications.coffee')

mockHangoutVideoNotify = (endpoint, channel, text, username, icon_url, parse, done)->
  slack = nock('https://slack.com', allowUnmocked: true)
                .post('/api/chat.postMessage',channel: 'C0TLAE1MH',
                  text: 'Video/Livestream for undefined: undefined', username: 'jon', icon_url:'jon.jpg', parse: 'full')
                .reply(200, {
                  ok: false,
                  error: 'not_authed'
                 });
  res = {}
  res.writeHead = -> {}
  res.end = -> {} 
  req = { body: { host_name: 'jon', host_avatar: 'jon.jpg', type: 'Scrum' } }
  req.post = -> {} 
  @routes_functions['/hubot/hangouts-video-notify'](req,res)
  setTimeout (->
    done()
  ), 1
  slack

describe 'AV Hangout Notifications', ->
  beforeEach ->
    routes_functions = {}
    avHangoutsNotifications({router: { post: (s,f) -> routes_functions[s] = f } })
    @routes_functions = routes_functions

  it 'has appropriate routes', ->
    expect(typeof @routes_functions['/hubot/hangouts-notify']).toBe("function")
    expect(typeof @routes_functions['/hubot/hangouts-video-notify']).toBe("function")

  describe 'hangouts-video-notify', ->
    beforeEach (done) ->
      @slack = nock('https://slack.com', allowUnmocked: true)
                .post('/api/chat.postMessage',channel: 'C0TLAE1MH',
                  text: 'Video/Livestream for undefined: undefined', username: 'jon', icon_url:'jon.jpg', parse: 'full')
                .reply(200, {
                  ok: false,
                  error: 'not_authed'
                 });
      res = {}
      res.writeHead = -> {}
      res.end = -> {} 
      req = { body: { host_name: 'jon', host_avatar: 'jon.jpg', type: 'Scrum' } }
      req.post = -> {} 
      @routes_functions['/hubot/hangouts-video-notify'](req,res)
      setTimeout (->
        done()
      ), 1

    it 'should post scrum hangout link to general channel', (done) ->
      mockHangoutVideoNotify()
      expect(@slack.isDone()).toBe(true, 'expected HTTP endpoint was not hit')
      done()
