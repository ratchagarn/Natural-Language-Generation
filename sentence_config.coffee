
###
# Sentence Type
###

# JittaLine
exports.jittaline =
  getSimpleSentenceList: (data, simpleSentences) ->
    if typeof data.displayInfo.oldLine != 'undefined'
      group = data.displayInfo.oldLine + "_" + data.displayInfo.newLine
      if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][group])
        simpleSentences[data.sentenceType][group][data.level]
      else
        ['Error']
    else
      simpleSentences.default.na

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
    oldScore = if typeof data.oldScore == 'undefined' then 0 else data.oldScore
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][oldScore] && simpleSentences[data.sentenceType][oldScore][data.newScore])
      simpleSentences[data.sentenceType][oldScore][data.newScore]
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
    oldScore = if typeof data.oldScore == 'undefined' then 0 else data.oldScore
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][oldScore] && simpleSentences[data.sentenceType][oldScore][data.newScore])
      simpleSentences[data.sentenceType][oldScore][data.newScore]
    else
      ['Error']

# CapEx
exports.capex =
  getSimpleSentenceList: (data, simpleSentences) ->
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][data.levelType])
      simpleSentences[data.sentenceType][data.levelType]
    else
      ['Error']

# Error
exports.capex =
  getSimpleSentenceList: (data, simpleSentences) ->
    if(simpleSentences[data.sentenceType] && simpleSentences[data.sentenceType][data.levelType])
      simpleSentences[data.sentenceType][data.levelType]
    else
      ['Error']