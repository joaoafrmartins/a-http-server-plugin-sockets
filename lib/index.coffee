merge = require 'lodash.merge'

module.exports = (next) ->

  @config.sockets = merge require('./config'), @config?.sockets or {}
