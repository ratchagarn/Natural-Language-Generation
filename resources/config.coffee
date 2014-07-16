# Price
exports.price =
  getDifference: (newData, oldData) ->
    ((newData - oldData)/oldData)*100

  getDisplayInfo: (data, settings) ->
    precision = settings.precision
    percentDiff = Math.abs(data.difference)
    result = {}
    result.title = "the " + data.title.toLowerCase()
    result.oldNumber = data.oldData.toFixed(precision) + " " + data.currency
    result.newNumber = data.newData.toFixed(precision) + " " + data.currency
    result.difference = Math.abs(data.newData - data.oldData).toFixed(precision) + " " + data.currency
    if(percentDiff.toFixed(0) == "0")
      result.differencePercent = percentDiff.toFixed(2) + "%"
    else
      result.differencePercent = percentDiff.toFixed(precision) + "%"
    result

  calculatePriority: (difference, prioritySettings) ->
    if(difference > 0)
      newPriority = prioritySettings.init + (prioritySettings.positiveFactor * difference)
    else
      newPriority = prioritySettings.init + (prioritySettings.negativeFactor * Math.abs(difference))
    newPriority.toFixed(0)

  calculateLevel: (difference, levelSettings) ->
    absoluteDifference = Math.abs(difference)
    if(absoluteDifference < levelSettings.threshold)
      level = 0
    else
      level = Math.ceil(absoluteDifference/levelSettings.sensitiveness)
      level = 3 if(level > 3)
      level = -3 if(level < -3)
    level

# Jitta Score
exports.score =
  getDifference: (newData, oldData) ->
    (newData - oldData)

  getDisplayInfo: (data, settings) ->
    precision = settings.precision
    result = {}
    result.title = data.title.charAt(0).toUpperCase() + data.title.slice(1).toLowerCase()
    result.oldNumber = data.oldData.toFixed(precision)
    result.newNumber = data.newData.toFixed(precision)
    result.difference = Math.abs(data.difference).toFixed(precision)
    result

  calculatePriority: (difference, prioritySettings) ->
    if(difference > 0)
      newPriority = prioritySettings.init + (prioritySettings.positiveFactor * difference)
    else
      newPriority = prioritySettings.init + (prioritySettings.negativeFactor * Math.abs(difference))
    newPriority.toFixed(0)

  calculateLevel: (difference, levelSettings) ->
    absoluteDifference = Math.abs(difference)
    if(absoluteDifference < levelSettings.threshold)
      level = 0
    else
      level = Math.ceil(absoluteDifference/levelSettings.sensitiveness)
      level = 3 if(level > 3)
      level = -3 if(level < -3)
    level