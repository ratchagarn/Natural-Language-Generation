#
# +++ แนวคิด +++
#
# 1. Data Preparation
# ข้อมูลที่เข้าฟังก์ชัน generate จะเป็นอาเรย์ของ object ที่ประกอบไปด้วย properties [title*, newData*, oldData, alwaysShow]
# จากนั้นจึงไปเรียกฟังก์ชันต่างๆ เพื่อจัดเตรียมข้อมูลที่จำเป็นในการสร้างประโยคได้แก่
# - displayInfo: object ที่เก็บสตริงที่ปรับอยู่ในรูปพร้อมใช้งาน (พร้อมนำไปแทนค่าใน pattern ประโยค)
# - priority: คำนวณหาค่า priority ของประโยค โดยใช้ค่า default priority ที่มีอยู่ในไฟล์ setting
# - level: คำนวณค่าความรุนแรงในการเปลี่ยนแปลงของข้อมูล
# - group: จัดกลุ่มว่าข้อมูลใดมีลักษณะเหมือนกัน สามารถนำไปรวบเป็นประโยคเดียวกันได้หรือใช้รูปประโยคเดียวกันได้บ้าง
# - type: บอกลักษณะของการเปลี่ยนแปลงว่าเป็นไปในทางบวกหรือลบ
# เมื่อได้ข้อมูลที่จำเป็นสำหรับใช้สร้างประโยคแล้ว จะเลือกข้อมูลตามความสำคัญมา n ข้อมูลเพื่อใช้สร้างประโยค
#
# 2. Sentence Generation
# ข้อมูลที่ได้จากขั้นตอนข้างบนจะถูกเอาไปกรุ๊ปตาม group ของข้อมูล เพื่อดูว่ามีข้อมูลไหนจัดกลุ่มเข้าด้วยกันได้บ้าง จากนั้นจึงนำไปสร้างเป็นประโยค
#
# +++ ปัญหา +++
# getDisplayInfo(...), calculatePriority(...) และ calculateLevel(...) มีวิธีการคิดที่แตกต่างกันขึ้นอยู่กับลักษณะของข้อมูล
# 

#
# ตัวอย่าง settings
# 
# integer
# 2 dp floating number (e.g. 22.34)

config = require("./resources/config.coffee")
settings = require("./resources/settings2.json")
sentences = require("./resources/sentences2.json")
input = require("./resources/input.json")
_ = require("underscore")

#
# Data Preparation
# 

# nData คือจำนวน Data ที่ต้องการ
generate = (data, nData) ->
  data = getAttrs(data)
  data = selectData(data, nData)
  # console.log data
  result = buildSentences(data);
  console.log result
  return result.join(' ');

###
Add more required attributes
@param  {object} data
@return {object} new data with more attributes
###
getAttrs = (data) ->
  for i of data
    if(settings[data[i].title])
      name = data[i].title
    else
      name = 'default'
    data[i].dataGroup = settings[name].dataGroup
    data[i].difference = getDifference(data[i])
    data[i].sentenceGroup = settings[name].sentenceGroup
    data[i].contentGroup = settings[name].contentGroup
    data[i].displayInfo = getDisplayInfo(data[i], settings[name])
    data[i].priority = calculatePriority(data[i], settings[name])
    data[i].level = calculateLevel(data[i], settings[name])
    data[i].type = calculateType(data[i].level)
  data

###
Get the difference between old value and current value
@param  {any}    newData
@param  {any}    oldData
@return {object} difference value
###
getDifference = (data) ->
  # Override
  if(config[data.dataGroup] && config[data.dataGroup].getDifference)
    console.log("Override " + data.title + " for getDifference")
    return config[data.dataGroup].getDifference(data.newData, data.oldData);
  # Default
  data.newData - data.oldData

###
Prepare strings required to show in the sentence
@param  {object} data
@param  {object} settings
@return {object} information required to display in the sentence
###
getDisplayInfo = (data, settings) ->
  # Override
  if(config[data.dataGroup] && config[data.dataGroup].getDisplayInfo)
    console.log("Override " + data.title + " for getDisplayInfo")
    return config[data.dataGroup].getDisplayInfo(data, settings)
  # Default
  precision = settings.precision
  result = {}
  result.title = data.title.toLowerCase()
  result.oldData = data.oldData.toFixed(precision)
  result.newData = data.newData.toFixed(precision)
  result.difference = Math.abs(data.difference).toFixed(precision)
  result

###
Calculate the priority of change
@param  {object} data
@param  {object} settings
@return {number} new priority
###
calculatePriority = (data, settings) ->
  # Override
  if(config[data.dataGroup] && config[data.dataGroup].calculatePriority)
    console.log("Override " + data.title + " for calculatePriority")
    settings.priority.init = data.priority if(! typeof(data.priority) == undefined)
    return config[data.dataGroup].calculatePriority(data.difference, settings.priority)
  # Default
  prioritySettings = settings.priority
  if(data.difference > 0)
    newPriority = prioritySettings.init + (prioritySettings.positiveFactor * data.difference)
  else
    newPriority = prioritySettings.init + (prioritySettings.negativeFactor * Math.abs(data.difference))
  parseInt(newPriority.toFixed(0))


###
Calculate the intesity of change
@param  {object} data
@param  {object} settings
@return {number} intensity of the change
###
calculateLevel = (data, settings) ->
  # Override
  if(config[data.dataGroup] && config[data.dataGroup].calculateLevel)
    console.log("Override " + data.title + " for calculateLevel")
    return config[data.dataGroup].calculateLevel(data.difference, settings.level)
  # Default
  levelSettings = settings.level
  absoluteDifference = Math.abs(data.difference)
  if(absoluteDifference < levelSettings.threshold)
    level = 0
  else
    level = Math.ceil(data.difference/levelSettings.sensitiveness)
    level = 3 if(level > 3)
    level = -3 if(level < -3)
  level


calculateType = (level) ->
  if level > 0
    "positive"
  else if level < 0
    "negative"
  else
    "neutral"

# เลือกข้อมูลมาเป็นจำนวน nData และเรียงประโยคอีกครั้งตาม priority (มากไปน้อย)
selectData = (data, nData) ->
  groupedData = groupData(data)
  result = groupedData.alwaysShow
  if result.length < nData
    nRemaining = nData - result.length
    result = result.concat(groupedData.sortedData.slice(0, nRemaining))
  result.sort (a, b) ->
    b.priority - a.priority

  result

# แบ่งกลุ่มเป็นประโยคที่บังคับแสดง (always show) กับประโยคที่ไม่บังคับแสดง (เรียงตาม priority จากมากไปน้อย)
groupData = (data) ->
  data = _.groupBy(data, "alwaysShow")
  data.sortedData = []
  data.alwaysShow = []
  if data[false]
    data[false].sort (a, b) ->
      b.priority - a.priority

    data.sortedData = data[false]
  data.alwaysShow = data[true]  if data[true]
  data

#
# Sentence Generation
# 

###
Group data into contentGroups and loop through each
contentGroup to create sentence(s)
@param  {array} data - array sorted by priority but not grouped
@return {array} array of sentences
###
buildSentences = (data) ->
  result = []
  data = _.groupBy(data, "contentGroup")
  for group of data
    if(data[group].length > 2)
      i = 0
      while i < data[group].length
        if i + 1 is data[group].length
          result.push(buildCompoundSentence([data[group][i]]))
        else
          result.push(buildCompoundSentence([data[group][i], data[group][parseInt(i)+1]]))
        i = i + 2
    else
      result.push(buildCompoundSentence(data[group]))
  result

buildSimpleSentence = (data) ->
  if(sentences.simpleSentences[data.sentenceGroup] && sentences.simpleSentences[data.sentenceGroup][data.type] && sentences.simpleSentences[data.sentenceGroup][data.level.toString()])
    return replaceStr(sentences.simpleSentences[data.sentenceGroup][data.type][data.level.toString()], data.displayInfo)
  replaceStr(sentences.simpleSentences['default'][data.type][data.level.toString()], data.displayInfo)

buildCompoundSentence = (data) ->
  types = _.pluck(data, 'type');
  type = types.join('_')
  console.log type
  moreData = _.pluck(addSimpleSentence(data), 'displayInfo');
  selectedSentences = _.find(sentences.compoundSentences, (group) ->
    _.contains(group.type, type);
  )
  # selectedSentences = _.findWhere(sentences.compoundSentences, {newsroom: "The New York Times"});
  # console.log moreData
  capitalize(replaceCombinedStr(selectedSentences.sentences, moreData))
  # if(sentences.compound && sentences.compound[type] && sentences.compound[type])
  #   return replaceStr(sentences.simpleSentences[group][type][data.level.toString()], data.displayInfo)
  # replaceStr(sentences.simpleSentences['default'][data.type][data.level.toString()], data.displayInfo)


addSimpleSentence = (data) ->
  for i of data
    data[i].displayInfo.sentence = buildSimpleSentence(data[i])
  data
###
Replace sentence pattern with string in data object
(single sentence, no capitalization or full stop)
@param  {array}  patterns - array of sentences
@param  {object} data - displayInfo object
@return {string} final sentence
###
replaceStr = (patterns, data) ->
  pattern = _.sample(patterns)
  for key of data
    pattern = pattern.replace("{" + key + "}", data[key])
  pattern

###
Replace sentence pattern with string in data object
(combined sentence, with capitalization and full stop)
@param  {array}  patterns - array of sentences
@param  {array}  data - array of displayInfo object
@return {string} final sentence
###
replaceCombinedStr = (patterns, data) ->
  pattern = _.sample(patterns)
  for i of data
      for key of data[i]
        pattern = pattern.replace("{" + key + "." + i + "}", data[i][key])
  pattern

###
Change the first character of the string to capital
@param  {string} data
@return {string} capitalized string
###
capitalize = (data) ->
  data.charAt(0).toUpperCase() + data.slice(1);

#
# ตัวอย่าง input ของ generate function
# 
# input = [
generate(input.data, 50)

#
#generate
#[{title*
#oldData*
#newData
#always_show}]
#
#buildSentence
#[{title*
#dataFormat*
#oldData*
#newData
#level (-3,-2,-1,0,1,2,3)
#type (positive, negative, neutral)
#displayInfo
#group*}]
#
#TODO
#- build compound sentence by difference combination of levels?
#- 'No oldData' case
#- full, medium, short sentences
#- display format is not in the same as the input format (e.g. input: 2.50, display: 2.5 baht)
#