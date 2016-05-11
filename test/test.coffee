channelJson             = require '../channelJson.json'
OctobluRequestFormatter = require '../octoblu-request-formatter.coffee'
format                  = new OctobluRequestFormatter(channelJson)

console.log format.buildSchema()
