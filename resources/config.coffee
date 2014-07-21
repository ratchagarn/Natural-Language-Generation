words = require("./words.json")
exports.val = require("./config.json")

# Price
exports.price =
  getDifference: (data) ->
    ((data.newData - data.oldData)/data.oldData)*100

  getDisplayInfo: (data, config) ->
    precision = config.precision
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
  getDisplayInfo: (data, config) ->
    precision = config.precision
    result = {}
    result.title = data.title.charAt(0).toUpperCase() + data.title.slice(1).toLowerCase()
    result.oldData = data.oldData.toFixed(precision)
    result.newData = data.newData.toFixed(precision)
    result.difference = Math.abs(data.difference).toFixed(precision)
    result

# Loss Chance
exports.loss =
  getDisplayInfo: (data, config) ->
    precision = config.precision
    result = {}
    result.title = data.title.toLowerCase()
    result.oldData = data.oldData.toFixed(precision) + "%"
    result.newData = data.newData.toFixed(precision) + "%"
    absoluteDifference = Math.abs(data.difference)
    precision = 2 if absoluteDifference.toFixed(0) == "0"
    result.difference = absoluteDifference.toFixed(precision) + "%"
    result

# Jitta Signs
exports.sign =
  getAttrs: (data) ->
    data.oldScore = @getScore(data.title, data.oldData)
    data.newScore = @getScore(data.title, data.newData)
    if(data.newScore == '0')
      data.hidden = true
    data

  getDisplayInfo: (data, config) ->
    precision = config.precision
    result = {}
    result.title = data.title.toLowerCase()
    result.title = "CapEx" if data.title == "CapEx"
    result.oldData = data.oldData.toLowerCase()
    result.newData = data.newData.toLowerCase()
    result

  getScore: (title, data) ->
    for item of words[title]
      pattern = new RegExp(item, "g");
      if pattern.test(data)
        return words[title][item]
    return null

  getDifference: (data) ->
    parseInt(data.newScore) - parseInt(data.oldScore)

###
# Sentence Type
###

# Earning
exports.earning =
  getSimpleSentenceList: (data, simpleSentences) ->
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][data.newScore])
      simpleSentences[data.sentenceType][data.newScore]
    else
      ['Error']

# Operating
exports.operating =
  getSimpleSentenceList: (data, simpleSentences) ->
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][data.levelType])
      simpleSentences[data.sentenceType][data.levelType]
    else
      ['Error']

# Debt
exports.debt =
  getSimpleSentenceList: (data, simpleSentences) ->
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType].all)
      simpleSentences[data.sentenceType].all
    else
      ['Error']

# Return on Equity
exports.roe =
  getSimpleSentenceList: (data, simpleSentences) ->
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][data.oldScore] && simpleSentences[data.sentenceType][data.oldScore][data.newScore])
      simpleSentences[data.sentenceType][data.oldScore][data.newScore]
    else
      ['Error']

# Dividend Payout
exports.dividend =
  getSimpleSentenceList: (data, simpleSentences) ->
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][data.levelType])
      simpleSentences[data.sentenceType][data.levelType]
    else
      ['Error']

# Share Repurchase
exports.repurchase =
  getSimpleSentenceList: (data, simpleSentences) ->
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][data.oldScore] && simpleSentences[data.sentenceType][data.oldScore][data.newScore])
      simpleSentences[data.sentenceType][data.oldScore][data.newScore]
    else
      ['Error']

# CapEx
exports.capex =
  getSimpleSentenceList: (data, simpleSentences) ->
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][data.levelType])
      simpleSentences[data.sentenceType][data.levelType]
    else
      ['Error']