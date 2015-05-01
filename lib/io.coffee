{ createServer } = require 'http'

io = require 'socket.io'

Client = require './client'

module.exports = class SocketIO

  constructor: (next, app, config) ->

    if config is undefined then config = require '../config'

    Object.defineProperty @, "server", value: createServer app

    Object.defineProperty @, "io", value: io.listen @server

    @io.configure =>

      Object.keys(config.io).map (key) =>

        @io.set key, config.io[key]

  ###

    @server.listen app.get 'port', () =>

      @io.sockets.on 'connection', (socket) =>

        context = { socket: socket, next: next }

        socket.on 'join', @onJoin.bind context

        socket.on 'disconnect', @onDisconnect.bind context



  onJoin: (data) ->

    new Client data.uuid, (err, client) =>

      if err then return @next err, null

      @socket.set 'client', client

      client.subscribe @socket

  onDisconnect: ->

    @socket.get 'client', (err, client) =>

      if client is null then return

      client.unsubscribe()

      client.publish 'disconnect', uuid: client.uuid

      client.destroy()

  ###
