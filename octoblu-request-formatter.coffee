_               = require 'lodash'
SchemaGenerator = require './schema-generator.coffee'
debug           = require('debug')('request-formatter:index')

class OctobluRequestFormatter
  constructor: (channelJson) ->
    @channelJson = channelJson
    @resources   = @channelJson.application.resources
    @schemaGenerator = new SchemaGenerator(@resources)

  processMessage: (payload, auth, defaultUrlParams) =>
    {endpoint, params} = payload
    requestParams = params

    target = _.find @resources, (item) -> item.displayName == endpoint
    debug 'Found Endpoint', target

    {url, params, httpMethod} = target

    bodyParams  = @matchStyleParams params, requestParams, 'body'
    queryParams = @matchStyleParams params, requestParams, 'query'
    urlParams   = @matchStyleParams params, requestParams, 'url'

    debug 'body params', bodyParams
    debug 'query params', queryParams

    requestUrl = @replaceUrlParams url, urlParams, defaultUrlParams
    debug 'replaceUrlParams: ', requestUrl

    requestOptions = @formatRequest requestUrl, bodyParams, queryParams, httpMethod
    debug 'sending request', requestOptions
    requestOptions

  matchStyleParams: (params, requestParams, style) =>
    styleParams = {}
    paramsToMatch = _.map params, (param) ->
      return param.name if param.style == style

    _.each requestParams, (value, key) =>
      _.set(styleParams, key, value) unless _.indexOf(paramsToMatch, key) == -1

    return styleParams

  replaceUrlParams: (url, params, defaults) =>
    params = _.extend params, defaults
    _.each params, (value, key) =>
      re = new RegExp(key, 'g')
      url = url.replace(re, value)
    return url

  formatRequest: (requestUrl, bodyParams, queryParams, httpMethod) =>
    config =
      headers:
        'Accept': 'application/json'
        'User-Agent': 'Octoblu/1.0.0'
        'x-li-format': 'json'
      uri: requestUrl
      method: httpMethod
      followAllRedirects: @channelJson.followAllRedirects ? true
      qs: queryParams

    config.strictSSL = false if @channelJson.skipVerifySSL

    if @channelJson.uploadData
      buf = new Buffer @channelJson.uploadData, 'base64'
      config.body = buf
      config.encoding = null
      config.headers['Content-Type'] = 'text/plain'
      delete config.headers['Accept']
    else
      if @channelJson.bodyFormat == 'json'
        json = @_omitEmptyObjects bodyParams
        config.json = json unless _.isEmpty(json)
        config.json = true if _.isEmpty(json)
      else
        config.form = bodyParams

    config

  buildSchema: () =>
    @schemaGenerator.generate()

  _omitEmptyObjects: (object) =>
  _.omit object, (value) =>
    _.isObject(value) && _.isEmpty(value)

module.exports = OctobluRequestFormatter
