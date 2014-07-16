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
input = require("./resources/input.json")
_ = require("underscore")

#
# Data Preparation
# 

# nData คือจำนวน Data ที่ต้องการ
generate = (data, nData) ->
  data = getAttrs(data)
  data = selectData(data, nData)
  console.log data
  return

# result = buildSentences(data[type]);
#return result;

###
Add more required attributes
@param  {object} data
@return {object} new data with more attributes
###
getAttrs = (data) ->
  for i of data
    data[i].dataGroup = settings[data[i].title].dataGroup
    data[i].difference = getDifference(data[i])
    data[i].displayGroup = settings[data[i].title].displayGroup
    data[i].displayInfo = getDisplayInfo(data[i], settings[data[i].title])
    data[i].priority = calculatePriority(data[i], settings[data[i].title])
    data[i].level = calculateLevel(data[i], settings[data[i].title])
    data[i].type = calculateType(data[i].level)
  data

###
Get the difference between old value and current value
@param  {any}    newData
@param  {any}    oldData
@return {object} difference value
###
getDifference = (data) ->
  config[data.dataGroup].getDifference(data.newData, data.oldData)

###
Prepare strings required to show in the sentence
@param  {object} data
@param  {object} settings
@return {object} information required to display in the sentence
###
getDisplayInfo = (data, settings) ->
  config[data.dataGroup].getDisplayInfo(data, settings)

###
Calculate the priority of change
@param  {object} data
@param  {object} settings
@return {number} new priority
###
calculatePriority = (data, settings) ->
  # override initial priority
  if (! typeof(data.priority) == undefined)
    settings.priority.init = data.priority
  config[data.dataGroup].calculatePriority(data.difference, settings.priority)


###
Calculate the intesity of change
@param  {object} data
@param  {object} settings
@return {number} intensity of the change
###
calculateLevel = (data, settings) ->
  config[data.dataGroup].calculateLevel(data.difference, settings.level)


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
buildSentences = (data) ->
  result = ""
  data = _.indexBy(data, "group")
  for group of data
    if data[group].length < 2
      result = result + " " + buildSimpleSentence(data[group][0])
    else
      typeGroupedData = _.indexBy(data[group], "type")
      for type of typeGroupedData
        result = result + " " + buildCompoundSentence(typeGroupedData[type])
  result
buildSimpleSentence = (data) ->
  0
buildCompoundSentence = (data) ->
  0

#
# ตัวอย่าง input ของ generate function
# 
# input = [

# {
# 	title: 'Loss Chance',
# 	oldData: 18.8,
# 	newData: 19.8,
# 	alwaysShow: false
# },
generate(input.data, 2)

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