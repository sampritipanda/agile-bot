nock = require('nock');
avHangoutsNotifications = require('../scripts/av-hangouts-notifications.coffee')

makeRequest = (routes_functions, type, project, done) ->
  res = {}
  res.writeHead = -> {}
  res.end = -> {}
  req = {body: {host_name: 'jon', host_avatar: 'jon.jpg', type: type, project: project}}
  req.post = -> {}
  routes_functions['/hubot/hangouts-video-notify'](req, res)
  setTimeout (->
    done()
  ), 2

# endpoint, channel, text, username, icon_url, parse,
mockHangoutVideoNotify = (routes_functions, channel, type, project, done) ->
  nock('https://slack.com', allowUnmocked: false)
    .post('/api/chat.postMessage',
      channel: channel,
      text: 'Video/Livestream for undefined: undefined',
      username: 'jon',
      icon_url: 'jon.jpg',
      parse: 'full'
    )
    .reply(200, {
      ok: false,
      error: 'not_authed'
    });

describe 'AV Video Hangout Notifications', ->
  beforeEach ->
    routes_functions = {}
    avHangoutsNotifications({router: {post: (s, f) -> routes_functions[s] = f}})
    @routes_functions = routes_functions

  it 'has appropriate routes', ->
    expect(typeof @routes_functions['/hubot/hangouts-video-notify']).toBe("function")

  describe 'hangouts-video-notify for scrum', ->
    beforeEach (done) ->
      @slack = mockHangoutVideoNotify(@routes_functions, 'C0TLAE1MH', 'Scrum', 'localsupport', done)
      makeRequest(@routes_functions, 'Scrum', 'localsupport', done)

    it 'should post scrum video link to general channel', (done) ->
      expect(@slack.isDone()).toBe(true, 'expected HTTP endpoint was not hit')
      done()

  describe 'hangouts-video-notify for pairing', ->
    beforeEach (done) ->
      @slack = mockHangoutVideoNotify(@routes_functions, 'C0TLAE1MH', 'PairProgramming', 'localsupport', done)
      mockHangoutVideoNotify(@routes_functions, 'C0KK907B5', 'PairProgramming', 'localsupport', done)
      makeRequest(@routes_functions, 'PairProgramming', 'localsupport', done)

    it 'should post pair hangout link to general channel', (done) ->
      expect(@slack.isDone()).toBe(true, 'expected HTTP endpoint was not hit')
      done()

  describe 'hangouts-video-notify for pairing on cs169', ->
    beforeEach (done) ->
      @slack = mockHangoutVideoNotify(@routes_functions, 'C02A6835V', 'PairProgramming', 'cs169', done)
      makeRequest(@routes_functions, 'PairProgramming', 'cs169', done)
    
    it 'should not post pair hangout link to mooc channel on slack', (done) ->
      expect(@slack.isDone()).toBe(false, 'unexpected HTTP endpoint was hit')
      done()

