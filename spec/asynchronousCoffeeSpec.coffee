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