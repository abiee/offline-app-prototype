class HeartBeat
  _isOnline: false
  _isRunning: false
  heartbeatPeriod: 20000
  timeoutPeriod: 15000

  constructor: (callback) ->
    @callback = callback

  checkServerAvailability: ->
    $.ajax
      type: 'GET'
      url: '/api/ping'
      cache: false
      timeout: @timeoutPeriod
    .then =>
      @_isOnline = true
    .fail =>
      @_isOnline = false
    .always =>
      if _.isFunction @callback then @callback()

  start: ->
    if not @_isRunning
      @checkServerAvailability()
      setInterval _.bind(@checkServerAvailability, @), @heartbeatPeriod

  isOnline: -> @_isOnline
