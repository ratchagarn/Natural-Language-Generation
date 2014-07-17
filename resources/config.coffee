# Price
exports.price =
  getDifference: (newData, oldData) ->
    ((newData - oldData)/oldData)*100

  getDisplayInfo: (data, settings) ->
    precision = settings.precision
    percentDiff = Math.abs(data.difference)
    result = {}
    result.title = "the " + data.title.toLowerCase()
    result.oldData = data.oldData.toFixed(precision) + " " + data.currency
    result.newData = data.newData.toFixed(precision) + " " + data.currency
    result.differencePrice = Math.abs(data.newData - data.oldData).toFixed(precision) + " " + data.currency
    if(percentDiff.toFixed(0) == "0")
      result.difference = percentDiff.toFixed(2) + "%"
    else
      result.difference = percentDiff.toFixed(precision) + "%"
    result

# Jitta Score
exports.score =
  getDisplayInfo: (data, settings) ->
    precision = settings.precision
    result = {}
    result.title = data.title.charAt(0).toUpperCase() + data.title.slice(1).toLowerCase()
    result.oldData = data.oldData.toFixed(precision)
    result.newData = data.newData.toFixed(precision)
    result.difference = Math.abs(data.difference).toFixed(precision)
    result

# Loss Chance
exports.loss =
  getDisplayInfo: (data, settings) ->
    precision = settings.precision
    result = {}
    result.title = data.title.toLowerCase()
    result.oldData = data.oldData.toFixed(precision) + "%"
    result.newData = data.newData.toFixed(precision) + "%"
    result.difference = Math.abs(data.difference).toFixed(precision) + " " + data.currency
    absoluteDifference = Math.abs(data.difference)
    precision = 2 if absoluteDifference.toFixed(0) == "0"
    result.difference = absoluteDifference.toFixed(precision) + "%"
    result
