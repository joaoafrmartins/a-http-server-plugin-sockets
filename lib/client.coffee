Redis = require './redis'

module.exports = class SocketIOClient

  @uuid: ->

    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else (r & 0x3|0x8)
      v.toString(16)
    )

  constructor: (@uuid, next) ->

    @uuid ?= "anon-#{IOClient.uuid()}"

    @defaultEvent ?= "data"

    @channel = "#{@uuid}-channel"

    new Redis (err, redis) =>

      redis.connect (err, pubClient) =>

        @pub = pubClient

        new Redis (err, redis) =>

          redis.connect (err, subClient) =>

            @sub = pubClient

            next null, @

  event: (name, data) ->

    JSON.stringify

      name: name

      data: data

  subscribe: (socket) ->

    socket.removeListener "#{@channel}", @channel

    socket.on "#{@channel}", (data) => @publish data

    @sub.on 'message', (channel, message) ->

      socket.emit channel, message

    @sub.on 'subscribe', =>

      @publish 'subscribe', { uuid: @uuid }

    @sub.subscribe "#{@channel}"

  unsubscribe: ->

    @sub.unsubscribe "#{@channel}"

  publish: (name, data) ->

    if typeof name is "object"

      data = name?.data or name

      name = name?.name or @defaultEvent

    @pub.publish "#{@channel}", @event name, data

  destroy: ->

    unless @sub is null then @sub.quit()

    unless @pub is null then @pub.quit()
