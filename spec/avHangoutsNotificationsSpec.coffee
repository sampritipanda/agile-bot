nock = require('nock');
avHangoutsNotifications = require('../scripts/av-hangouts-notifications.coffee')

makeRequest = (routes_functions, type, project, done) ->
  res = {}
  res.writeHead = -> {}
  res.end = -> {}
  req = {body: {host_name: 'jon', host_avatar: 'jon.jpg', type: type, project: project}}
  req.post = -> {}
  routes_functions['/hubot/hangouts-notify'](req, res)
  setTimeout (->
    done()
  ), 2

mockSlackHangoutNotify = (routes_functions, channel, type, project) ->
  text = if type == "Scrum" || channel == 'C02A6835V' then '@here undefined: undefined' else 'undefined: undefined'
  nock('https://api.gitter.im')
    .get('/v1/rooms/55e42db80fc9f982beaf2725/chatMessages')
    .reply(200, [])
  nock("https://api.gitter.im")
    .post("/v1/rooms/56b8bdffe610378809c070cc/chatMessages")
    .reply(200, {error: 'not_authed'})
  nock('https://slack.com', allowUnmocked: false)
    .post('/api/chat.postMessage',
      channel: channel,
      text: text,
      username: 'jon'
      icon_url: 'jon.jpg',
      parse: 'full')
    .reply(200, {
      ok: false,
      error: 'not_authed'
    })

describe 'AV Hangout Notifications', ->
  beforeEach ->
    routes_functions = {}
    avHangoutsNotifications({router: {post: (s, f) -> routes_functions[s] = f}})
    @routes_functions = routes_functions

  it 'has appropriate routes', ->
    expect(typeof @routes_functions['/hubot/hangouts-notify']).toBe("function")

  describe 'hangouts-notify for scrum', ->
    beforeEach (done) ->
      @slack = mockSlackHangoutNotify(@routes_functions, 'C0TLAE1MH','Scrum', 'localsupport')
      makeRequest(@routes_functions, 'Scrum', 'localsupport', done)

    it 'should post hangout link to general channel', (done)->
      expect(@slack.isDone()).toBe(true, 'expected HTTP endpoint was not hit')
      done()

  describe 'hangouts-notify for pair programming', ->
    beforeEach (done) ->
      @slack = mockSlackHangoutNotify(@routes_functions, 'C0TLAE1MH', 'PairProgramming', 'localsupport', done)
      makeRequest(@routes_functions, 'PairProgramming', 'localsupport', done)

    it 'should post hangout link to general channel', (done) ->
      expect(@slack.isDone()).toBe(true, 'expected HTTP endpoint was not hit')
      done()

  describe 'hangouts-notify for pair programming on cs169', ->
    beforeEach (done) ->
      @slack = mockSlackHangoutNotify(@routes_functions, 'C02A6835V', 'PairProgramming', 'cs169', done)
      makeRequest(@routes_functions, 'PairProgramming', 'cs169', done)

    it 'should not post hangout link to mooc channel on slack', (done) ->
      expect(@slack.isDone()).toBe(false, 'unexpected HTTP endpoint was hit')
      done()

