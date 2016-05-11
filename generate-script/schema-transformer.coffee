_       = require '../node_modules/lodash'
channel = require '../channelJson.json'
fs      = require 'fs'

resources = channel.application.resources
count = 0

MESSAGE_SCHEMA = {
  type: 'object'
  properties:
    endpoint:
      type: 'string'
    params:
      type: 'object'
      properties: {}
}

ACTION_MAP = []

MESSAGE_FORM_SCHEMA = [
  {
    'key': 'endpoint'
    'type': 'select'
    'titleMap': []
  }
]

_.forEach resources, (resource) =>
  current = resource.displayName
  # count = count + 1
  ACTION_MAP.push {
    value: current
    name:  current
  }

  _.forEach resource.params, (param) =>
    if _.has MESSAGE_SCHEMA.properties.params.properties, param.name
      index = _.findIndex MESSAGE_FORM_SCHEMA, key: "params." + param.name
      MESSAGE_FORM_SCHEMA[index].condition = MESSAGE_FORM_SCHEMA[index].condition + " || model.endpoint == '" + current + "'"
    else
      MESSAGE_SCHEMA.properties.params.properties[param.name] = {
        title: param.displayName
        type: param.type
      }
      if param.type == "array"
        MESSAGE_SCHEMA.properties.params.properties[param.name].items = {
          type: "string"
        }
      MESSAGE_FORM_SCHEMA.push {
        key: "params." + param.name
        condition: "model.endpoint == '" + current + "'"
      }

MESSAGE_FORM_SCHEMA[0].titleMap = ACTION_MAP

newJson = {
  messageSchema: MESSAGE_SCHEMA
  messageFormSchema: MESSAGE_FORM_SCHEMA
}

fs.writeFile "./json/schema.json", JSON.stringify(newJson), (err) =>
    return console.log err if err

    console.log "The file was saved!"


# console.log MESSAGE_FORM_SCHEMA, MESSAGE_SCHEMA, ACTION_MAP

# class SchemaTransformer
#   constructor: (channelJson) ->
#
#
#
# module.exports = SchemaTransformer
