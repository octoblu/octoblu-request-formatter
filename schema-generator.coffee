_       = require 'lodash'

class SchemaGenerator
  constructor: (resources) ->
    @resources = resources

  generate: () =>
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

    _.forEach @resources, (resource) =>
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

    return {
      messageSchema: MESSAGE_SCHEMA
      messageFormSchema: MESSAGE_FORM_SCHEMA
    }


module.exports = SchemaGenerator
