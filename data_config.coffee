words = require("./resources/words.json")

# Jitta Line
exports.jittaline = 
  getAttrs: (data) ->
    data.oldNumber = @getNumber(data.oldData) if(typeof data.oldData != 'undefined')
    data.newNumber = @getNumber(data.newData)
    data

  getDifference: (data) ->
    if(typeof data.oldData != 'undefined')
      data.newNumber - data.oldNumber
    else
      'na'

  getNumber: (data) ->
    percentIndex = data.indexOf("%")
    status = data.substring(percentIndex + 2, percentIndex + 7)
    number = data.substring(0, percentIndex)
    number = number * -1  if status is "Below"
    number

  getStatus: (data) ->
    percentIndex = data.indexOf("%")
    data.substring(percentIndex + 2, percentIndex + 7)

  getDisplayInfo: (data, config) ->
    precision = config.precision
    result = {}
    result.title = "the price"
    result.newData = data.newData.toLowerCase()
    result.newNumber = Math.abs(data.newNumber.toFixed(precision))
    result.newLine = if data.newNumber < 0 then 'below' else 'above'
    if(typeof data.oldData != 'undefined')
        result.oldData = data.oldData.toLowerCase()
        result.oldNumber = Math.abs(data.oldNumber.toFixed(precision))
        result.oldLine = if data.oldNumber < 0 then 'below' else 'above'
        difference = data.newNumber - data.oldNumber
        result.difference = Math.abs(difference.toFixed(if difference.toFixed(0) == 0 then 2 else precision))
    result

# Price
exports.price =
  getDifference: (data) ->
    if(typeof data.oldData != 'undefined')
      ((data.newData - data.oldData)/data.oldData)*100
    else
      'na'

  getDisplayInfo: (data, config) ->
    precision = config.precision
    result = {}
    result.title = "the " + data.title.toLowerCase()
    if(typeof data.oldData != 'undefined')
      percentDiff = Math.abs(data.difference)
      result.oldData = data.oldData.toFixed(precision) + " " + data.currency
      result.differencePrice = Math.abs(data.newData - data.oldData).toFixed(precision) + " " + data.currency
      result.difference = percentDiff.toFixed(if percentDiff.toFixed(0) == 0 then 2 else precision) + "%"
    result.newData = data.newData.toFixed(precision) + " " + data.currency
    result

# Jitta Score
exports.score =
  getDisplayInfo: (data, config) ->
    precision = config.precision
    result = {}
    result.title = data.title.charAt(0).toUpperCase() + data.title.slice(1).toLowerCase()
    if(typeof data.oldData != 'undefined')
        result.oldData = data.oldData.toFixed(precision)
        result.difference = Math.abs(data.difference).toFixed(precision)
    result.newData = data.newData.toFixed(precision)
    result

# Loss Chance
exports.loss =
  getDisplayInfo: (data, config) ->
    precision = config.precision
    result = {}
    result.title = data.title.toLowerCase()
    result.newData = data.newData.toFixed(precision) + "%"
    if(typeof data.oldData != 'undefined')
      result.oldData = data.oldData.toFixed(precision) + "%"
      absoluteDifference = Math.abs(data.difference)
      precision = 2 if absoluteDifference.toFixed(0) == "0"
      result.difference = absoluteDifference.toFixed(precision) + "%"
    result

# Jitta Signs
exports.sign =
  getAttrs: (data) ->
    data.newScore = @getScore(data.title, data.newData)
    if(typeof data.oldData != 'undefined')
      data.oldScore = @getScore(data.title, data.oldData)
    if(data.newScore == '0')
      data.hidden = true
    data

  getDisplayInfo: (data, config) ->
    precision = config.precision
    result = {}
    result.title = data.title.toLowerCase()
    result.title = "CapEx" if data.title == "CapEx"
    result.newData = data.newData.toLowerCase()
    if(typeof data.oldData != 'undefined')
      result.oldData = data.oldData.toLowerCase()
    result

  getScore: (title, data) ->
    for item of words[title]
      pattern = new RegExp(item, "g");
      if pattern.test(data)
        return words[title][item]
    return null

  getDifference: (data) ->
    if(typeof data.oldData != 'undefined')
      parseInt(data.newScore) - parseInt(data.oldScore)
    else
      'na'

# Error
exports.error =
  getDisplayInfo: (data, config) ->
    result = {}
    result.title = data.title
    result.newData = data.newData.toLowerCase()
    result