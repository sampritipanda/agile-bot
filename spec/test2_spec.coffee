nock = require('nock');

slack = nock('https://slack.com')
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

  describe 'hangouts-video-notify', ->
    beforeEach (done) ->
      res = {}
      res.writeHead = -> {}
      res.end = -> {} 
      req = { body: { host_name: 'jon', host_avatar: 'jon.jpg', type: 'Scrum' } }
      req.post = -> {} 
      # console.log  @routes_functions['/hubot/hangouts-video-notify'].toString()
      @routes_functions['/hubot/hangouts-video-notify'](req,res)
      setTimeout (->
        done()
      ), 3000

    it 'should support async execution of test preparation and expectations', (done) ->
      expect(slack.isDone()).toBe(true)
      done()

describe 'Asynchronous specs', ->
  value = undefined
  beforeEach (done) ->
    setTimeout (->
      value = 0
      done()
    ), 1
  it 'should support async execution of test preparation and expectations', (done) ->
    value++
    expect(value).toBeGreaterThan 0
    done()