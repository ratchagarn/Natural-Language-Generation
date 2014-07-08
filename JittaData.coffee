_ = require("underscore")
require "coffee-script"

oldData = require("./old.json")
newData = require("./new.json")
words = require("./words.json").words
settings = require("./settings.json")
sentences = require("./sentences.json")

# JittaData = require("./JittaData")
# 
class JittaData

  constructor: (name, oldData, newData) ->
    @name = name
    @oldData = data
    @newData = data
    @priority = null
    @update = null

  replaceStr: (patterns, data) ->
    pattern = _.sample(patterns)
    for key of data
      pattern = pattern.replace("{" + key + "}", data[key])
    # console.log "afterReplace"
    pattern

class JittaFactor extends JittaData
  constructor: (name, oldData, newData) ->
    # console.log "const name"
    @name = name
    # console.log "const oldData"
    @oldData = oldData
    # console.log "const newData"
    @newData = newData
    # console.log "const Max"
    @max = @getMax()
    # console.log "const Min"
    @min = @getMin()
    # console.log "const priority"
    @priority = @getPriority()
    # console.log "const sensitiveness"
    @sensitiveness = @getSensitiveness()
    # console.log "const update"
    @update = @getUpdate()

  getMax: () ->
    # console.log "getMax"
    settings.quantitative[@name].max

  getMin: () ->
    # console.log "getMin"
    settings.quantitative[@name].min

  getPriority: () ->
    # console.log "getPriority"
    settings.quantitative[@name].priority

  getSensitiveness: () ->
    # console.log "getSensitiveness"
    settings.quantitative[@name].sensitiveness

  alwaysShow: () ->
    # console.log "alwaysShow"
    settings.quantitative[@name].always_show

  getUpdate: () ->
    # console.log "getUpdate"
    if(@alwaysShow() || @oldData != @newData)
      @buildSentence()
    else
      null

  buildSentence: () ->
    index = @getLevel()
    data = {
      name: @name,
      oldData: @oldData,
      newData: @newData,
      difference: @getDisplayDifference()
    }
    # console.log data
    # console.log "beforeReplace"
    @replaceStr(sentences.quantitative[index], data)

  getLevel: () ->
    scale = @sensitiveness / 5
    boundedDiff = @getBoundedDifference()
    level = Math.ceil(Math.abs(boundedDiff / scale))
    # console.log Math.abs(boundedDiff / scale)
    if boundedDiff > 0
      level = 5  if level > 5
    else
      level = level * -1
      level = -5  if level < -5
    # console.log "getLevel"
    level.toString()

  getDisplayDifference: () ->
    # console.log @newData
    # console.log @oldData
    Math.abs(@newData - @oldData).toFixed(2)

  getBoundedDifference: () ->
    # console.log "get bounded diff"
    (@newData - @oldData)/(@max - @min)

class JittaSign extends JittaData
  constructor: (name, oldData, newData) ->
    # console.log "const name"
    @name = name
    # console.log "const oldData"
    @oldData = oldData
    # console.log "const newData"
    @newData = newData
    # console.log "const priority"
    @priority = @getPriority()
    # console.log "const update"
    @update = @getUpdate()

  getPriority: () ->
    # console.log "getPriority"
    settings.qualitative[@name].priority

  alwaysShow: () ->
    # console.log "alwaysShow"
    settings.qualitative[@name].always_show

  getUpdate: () ->
    # console.log "getUpdate"
    if(@alwaysShow() || @hasUpdate())
      @buildSentence()
    else
      null
  
  hasUpdate: () ->
    if((@oldData != @newData && @newData != null) || (@oldData == null && @newData != null))
      true
    else
      false

  getDisplayData: (data) ->
    if(data == null)
      "no data"
    else
      data.toLowerCase()

  buildSentence: () ->
    index = @getLevel()
    data = {
      name: @name,
      oldData: @getDisplayData(@oldData),
      newData: @getDisplayData(@newData)
    }
    # console.log data
    @replaceStr(sentences.qualitative[index], data)

  getLevel: () ->
    # console.log @oldData
    # console.log @newData
    # console.log (newLevel - oldLevel).toString()
    if(@oldData == null && @newData == null)
      "null"
    else
      oldLevel = @getDataLevel(@oldData)
      newLevel = @getDataLevel(@newData)
      # console.log oldLevel
      # console.log newLevel
      (newLevel - oldLevel).toString()

  getDataLevel: (data) ->
    if(data == null)
      0
    else
      result = _.findWhere(words, {word: data})
      result.score

class JittaLine extends JittaFactor
  constructor: (name, oldData, newData) ->
    # console.log "const name"
    @name = name
    # console.log "const oldData"
    @oldData = @getNumber(oldData)
    # console.log "const newData"
    @newData = @getNumber(newData)
    # console.log "const Max"
    @oldDataFull = oldData
    @newDataFull = newData
    @max = 100
    # console.log "const Min"
    @min = 0
    # console.log "const priority"
    @priority = @getPriority()
    # console.log "const sensitiveness"
    @sensitiveness = @getSensitiveness()
    # console.log "const update"
    @update = @getUpdate()

  getNumber: (data) ->
    percentIndex = data.indexOf("%")
    status = data.substring(percentIndex + 2, percentIndex + 7)
    number = data.substring(0, percentIndex)
    number = number * -1  if status is "Below"
    # console.log number
    number

  getStatus: (data) ->
    percentIndex = data.indexOf("%")
    data.substring(percentIndex + 2, percentIndex + 7)

  getLevelStatus: () ->
    console.log @getStatus(@oldDataFull) + "_" + @getStatus(@newDataFull)
    @getStatus(@oldDataFull) + "_" + @getStatus(@newDataFull)

  getUpdate: () ->
    # console.log "getUpdate"
    if(@alwaysShow() || @oldData != @newData)
      @buildSentence()
    else
      null

  buildSentence: () ->
    status = @getLevelStatus()
    index = @getLevel()
    data = {
      name: @name,
      oldData: @oldDataFull,
      newData: @newDataFull,
      oldNumber: @oldData,
      newNumber: @newData
    }
    # console.log sentences.jitta_line[status][index]
    # console.log data
    # console.log "beforeReplace"
    @replaceStr(sentences.jitta_line[status][index], data)

class JittaPrice extends JittaData
  #todo

# for factor of oldData.qualitative
  # console.log factor
  # a = new JittaSign(factor, oldData.qualitative[factor], newData.qualitative[factor]);
  # a = new JittaFactor(factor, oldData.quantitative[factor], newData.quantitative[factor]);
  # console.log a
# a = new JittaLine()
# console.log oldData.quantitative
    


# a = new JittaFactor("Loss Chance", oldData.quantitative["Loss Chance"], newData.quantitative["Loss Chance"]);
a = new JittaLine("Jitta Line", oldData.jitta["Jitta Line"], newData.jitta["Jitta Line"])
console.log a
# console.log a.buildSentence()