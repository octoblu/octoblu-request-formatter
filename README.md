# Octoblu Request Formatter

Disclaimer: this is awesome, you want this


### Pseudo example

### crappy example payload
```cson
{
 "endpoint": "Add User",
 "params": {
     "attributes": "dfsf",
     "groups": "blarg"
 }
```

```coffee
OctobluRequestFormatter = require 'octoblu-request-formatter'
format                  = new OctobluRequestFormatter(channelJson)

onMessage: (message) =>
  @defaultUrlParams = {
  ':hostname': @options.host
  ':port': @options.port
  }
  @auth = {
    'username': @options.username
    'password': @options.password
  }

  requestParams = format.processMessage message.payload, @auth, @defaultUrlParams
  request requestParams, (error, response, body) ->
    # have fun!
```

### example response

```cson
{ Accept: 'application/json',
    'User-Agent': 'Octoblu/1.0.0',
    'x-li-format': 'json' },
 uri: 'fdfd.com:80/xenmobile/api/v1/localusersgroups/Bob',
 method: 'GET',
 followAllRedirects: true,
 qs: {},
 strictSSL: false,
 form: {} }

 ```
