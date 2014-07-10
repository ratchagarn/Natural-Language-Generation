_ = require("underscore")
require "coffee-script"

oldData = require("./old.json")
newData = require("./new.json")
words = require("./words.json")
settings = require("./settings.json")
sentences = require("./sentences.json")

# JittaData = require("./JittaData")

class JittaData

  constructor: (name, oldData, newData) ->
    @name = name
    @oldData = data
    @newData = data

  replaceStr: (patterns, data) ->
    pattern = _.sample(patterns)
    for key of data
      pattern = pattern.replace("{" + key + "}", data[key])
    @capitalize(pattern)

  capitalize: (data) ->
    data.charAt(0).toUpperCase() + data.slice(1);

class JittaPrice extends JittaData

  constructor: (name, oldData, newData) ->
    @name = name
    @displayName = "the price"
    @oldData = oldData
    @newData = newData
    @priority = @getPriority()
    @sensitiveness = @getSensitiveness()
    @update = @getUpdate()

  getPriority: () ->
    settings.jitta[@name].priority

  getSensitiveness: () ->
    settings.jitta[@name].sensitiveness

  alwaysShow: () ->
    settings.jitta[@name].always_show

  getUpdate: () ->
    if(@alwaysShow() || @oldData != @newData)
      @buildSentence()
    else
      null

  buildSentence: () ->
    index = @getLevel()
    data = {
      name: @displayName,
      oldData: @oldData,
      newData: @newData,
      difference: @getDisplayDifference()
    }
    @replaceStr(sentences.quantitative[index], data)

  getLevel: () ->
    boundedDiff = @getBoundedDifference()
    level = Math.ceil(Math.abs(boundedDiff / (@sensitiveness / 5)))
    if boundedDiff > 0
      level = 5  if level > 5
    else
      level = level * -1
      level = -5  if level < -5
    level.toString()

  getBoundedDifference: () ->
    boundedDiff = (@newData - @oldData)/@oldData
    boundedDiff = 1 if boundedDiff > 1
    boundedDiff = -1 if boundedDiff < -1
    boundedDiff

  getDisplayDifference: () ->
    Math.abs(@newData - @oldData)

class JittaSign extends JittaData

  constructor: (name, oldData, newData) ->
    @name = name
    @oldData = oldData
    @newData = newData
    @priority = @getPriority()
    @update = @getUpdate()

  getPriority: () ->
    settings.qualitative[@name].priority

  alwaysShow: () ->
    settings.qualitative[@name].always_show

  getUpdate: () ->
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
      name: @name.toLowerCase(),
      oldData: @getDisplayData(@oldData),
      newData: @getDisplayData(@newData)
    }
    @replaceStr(sentences.qualitative[index], data)

  getLevel: () ->
    oldLevel = @getDataLevel(@oldData)
    newLevel = @getDataLevel(@newData)
    if(newLevel == null)
      return "null"
    else
      (newLevel - oldLevel).toString()

  getDataLevel: (data) ->
    if(data == null)
      return null
    for item of words[@name]
      pattern = new RegExp(item, "g");
      if pattern.test(data)
        return words[@name][item]
    return null

class JittaFactor extends JittaPrice

  constructor: (name, oldData, newData) ->
    @name = name
    @displayName = name
    @oldData = oldData
    @newData = newData
    @max = @getMax()
    @min = @getMin()
    @priority = @getPriority()
    @sensitiveness = @getSensitiveness()
    @update = @getUpdate()

  getMax: () ->
    settings.quantitative[@name].max

  getMin: () ->
    settings.quantitative[@name].min

  getPriority: () ->
    settings.quantitative[@name].priority

  getSensitiveness: () ->
    settings.quantitative[@name].sensitiveness

  alwaysShow: () ->
    settings.quantitative[@name].always_show

  getDisplayDifference: () ->
    Math.abs(@newData - @oldData).toFixed(2)

  getBoundedDifference: () ->
    (@newData - @oldData)/(@max - @min)

class JittaLine extends JittaFactor

  constructor: (name, oldData, newData) ->
    @name = name
    @oldData = @getNumber(oldData)
    @newData = @getNumber(newData)
    @oldDataFull = oldData
    @newDataFull = newData
    @max = 100
    @min = 0
    @priority = @getPriority()
    @sensitiveness = @getSensitiveness()
    @update = @getUpdate()

  getNumber: (data) ->
    percentIndex = data.indexOf("%")
    status = data.substring(percentIndex + 2, percentIndex + 7)
    number = data.substring(0, percentIndex)
    number = number * -1  if status is "Below"
    number

  getStatus: (data) ->
    percentIndex = data.indexOf("%")
    data.substring(percentIndex + 2, percentIndex + 7)

  getLevelStatus: () ->
    @getStatus(@oldDataFull) + "_" + @getStatus(@newDataFull)

  getUpdate: () ->
    if(@alwaysShow() || @oldData != @newData)
      @buildSentence()
    else
      null

  buildSentence: () ->
    status = @getLevelStatus()
    index = @getLevel()
    data = {
      name: "the price",
      oldData: @oldDataFull.toLowerCase(),
      newData: @newDataFull.toLowerCase(),
      oldNumber: Math.abs(@oldData),
      newNumber: Math.abs(@newData)
    }
    @replaceStr(sentences.jitta_line[status][index], data)

listofSentences = {
  jitta: [],
  quantitative: [],
  qualitative: []
}

init = ->
  for factor of oldData.qualitative
    a = new JittaSign(factor, oldData.qualitative[factor], newData.qualitative[factor]);
    if(a.update)
      listofSentences.qualitative.push(a)

  for factor of oldData.quantitative
    a = new JittaFactor(factor, oldData.quantitative[factor], newData.quantitative[factor]);
    if(a.update)
      listofSentences.quantitative.push(a)

  a = new JittaLine("Jitta Line", oldData.jitta["Jitta Line"], newData.jitta["Jitta Line"])
  if(a.update)
    listofSentences.jitta.push(a)

  a = new JittaPrice("Price", oldData.jitta["Price"], newData.jitta["Price"])
  if(a.update)
    listofSentences.jitta.push(a)

  for type of listofSentences
    listofSentences[type] = _.sortBy(listofSentences[type], (item) ->
      item.priority
    )
  printSentences()

printSentences = ->
  for type of listofSentences
    for i of listofSentences[type]
      console.log listofSentences[type][i].update

testMatch = (key) ->
  for item of words[key]
    pattern = new RegExp(item, "g");
    # console.log item
    if pattern.test("High A B D High .* in the past 5 years")
      return words[key][item]

init()