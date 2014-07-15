/*
 +++ แนวคิด +++

 1. Data Preparation
 ข้อมูลที่เข้าฟังก์ชัน generate จะเป็นอาเรย์ของ object ที่ประกอบไปด้วย properties [title*, newData*, oldData, alwaysShow]
 จากนั้นจึงไปเรียกฟังก์ชันต่างๆ เพื่อจัดเตรียมข้อมูลที่จำเป็นในการสร้างประโยคได้แก่
 - displayInfo: object ที่เก็บสตริงที่ปรับอยู่ในรูปพร้อมใช้งาน (พร้อมนำไปแทนค่าใน pattern ประโยค)
 - priority: คำนวณหาค่า priority ของประโยค โดยใช้ค่า default priority ที่มีอยู่ในไฟล์ setting
 - level: คำนวณค่าความรุนแรงในการเปลี่ยนแปลงของข้อมูล
 - group: จัดกลุ่มว่าข้อมูลใดมีลักษณะเหมือนกัน สามารถนำไปรวบเป็นประโยคเดียวกันได้หรือใช้รูปประโยคเดียวกันได้บ้าง
 - type: บอกลักษณะของการเปลี่ยนแปลงว่าเป็นไปในทางบวกหรือลบ
 เมื่อได้ข้อมูลที่จำเป็นสำหรับใช้สร้างประโยคแล้ว จะเลือกข้อมูลตามความสำคัญมา n ข้อมูลเพื่อใช้สร้างประโยค

 2. Sentence Generation
 ข้อมูลที่ได้จากขั้นตอนข้างบนจะถูกเอาไปกรุ๊ปตาม group ของข้อมูล เพื่อดูว่ามีข้อมูลไหนจัดกลุ่มเข้าด้วยกันได้บ้าง จากนั้นจึงนำไปสร้างเป็นประโยค

 +++ ปัญหา +++
 getDisplayInfo(...), calculatePriority(...) และ calculateLevel(...) มีวิธีการคิดที่แตกต่างกันขึ้นอยู่กับลักษณะของข้อมูล
 */


/*
 Data Preparation
 */

// nData คือจำนวน Data ที่ต้องการ
function generate(data, nData){
	data = getAttrs(data);
	data = selectData(data, nData);
	result = buildSentences(data[type]);
	return result;
}

// เพิ่มข้อมูลสำหรับใช้ในการสร้างประโยค
function getAttrs(data){
	for(i in data){
		data[i].displayInfo = getDisplayInfo(data[i]);
		data[i].priority = calculatePriority(data[i].title, settings[data[i].title].priority, data[i].newData, data[i].oldData);
		data[i].level = calculateLevel(data[i].title, data[i].newData, data[i].oldData);
		data[i].type = calculateType(data[i].level);
		data[i].group = settings[data[i].title].group;
	}
	return data;
}

// เตรียมข้อมูลให้อยู่ในรูปที่พร้อมนำไปสร้างประโยค
// รูปแบบของ output ขึ้นอยู่กับ group ของข้อมูล
function getDisplayInfo(data){
	// json format depends on the group of data
	precision = settings[data.title].precision;
	result = {};
	result.title = data.title;
	result.oldNumber = data.oldData.toFixed(precision) + "%";
	result.newNumber = data.newData.toFixed(precision) + "%";
	result.difference = (data.newData - data.oldData).toFixed(precision) + "%";
	return result;
}

// คำนวณลำดับของประโยคว่าจะให้ขึ้นเป็นลำดับที่เท่าไร
function calculatePriority(title, defaultPriority, oldData, newData){
	return 0;
}

// คำนวณความรุนแรงของการเปลี่ยนแปลงเพื่อใช้ในการเลือกระดับของประโยค
function calculateLevel(title, oldData, newData){
	return 0;
}

function calculateType(level){
	if(level > 0){
		return 'positive';
	}
	else if(level < 0){
		return 'negative';
	}
	else{
		return 'neutral';
	}
}

// เลือกข้อมูลมาเป็นจำนวน nData และเรียงประโยคอีกครั้งตาม priority (มากไปน้อย)
function selectData(data, nData){
	groupedData = groupData(data);
	result = groupedData.alwaysShow;
	if(result.length < nData){
		nRemaining = nData - result.length;
		result = result.concat(groupedData.sortedData.slice(0, nRemaining));
	}
	result.sort(function(a, b) {
		return b.priority - a.priority;
	});
	return result;
}

// แบ่งกลุ่มเป็นประโยคที่บังคับแสดง (always show) กับประโยคที่ไม่บังคับแสดง (เรียงตาม priority จากมากไปน้อย)
function groupData(data){
	data = _.indexBy(data, 'always_show');
	x[false].sort(function(a, b) {
		return b.priority - a.priority;
	});
	data = {};
	data.alwaysShow = x[true];
	data.sortedData = x[false]
	return data;
}





/*
 Sentence Generation
 */

function buildSentences(data){
	result = "";
	data = _.indexBy(data, 'group');
	for(group in data){
		if(data[group].length < 2){
			result = result + " " + buildSimpleSentence(data[group][0]);
		}
		else{
			typeGroupedData = _.indexBy(data[group], 'type');
			for(type in typeGroupedData){
				result = result + " " + buildCompoundSentence(typeGroupedData[type]);
			}
		}
	}
	return result;
}

function buildSimpleSentence(data){
	return 0;
}

function buildCompoundSentence(data){
	return 0;
}


/*
 ตัวอย่าง input ของ generate function
 */
input = [
	{
		title: 'Jitta Score',
		oldData: 7.10,
		newData: 6.97,
		alwaysShow: true
	},
	{
		title: 'Price',
		oldData: 95.22,
		newData: 79.18,
		alwaysShow: false
	},
	{
		title: 'Loss Chance',
		oldData: 18.8,
		newData: 19.8,
		alwaysShow: false
	},
];
generate(input, 2);

/*
 ตัวอย่าง settings
 */
settings = {
	'Jitta Score': {
		'priority': 1,
		'group': 'score',
		'precision': '0' // integer
	},
	'Price': {
		'priority': 2,
		'group': 'price',
		'precision': '2' // 2 dp floating number (e.g. 22.34)
	}
};

/*
 ตัวอย่าง sentence
 */
simpleSentences = {
	'score': { // group ของข้อมูล
		'positive': { // type ของข้อมูล
			'3': [
				"{name} is {newNumber}",
				"{name} has increased from {oldNumber} to {newNumber}"
			],
			'2': [],
			'1': []
		},
		'neutral': {
			'0': []
		},
		'negative': {
			'-1': [],
			'-2': [],
			'-3': []
		}
	}
	'price': {}
}
compoundSentences = {
	'score': { // group ของข้อมูล
		'positive_positive': {
			"{name.1} and {name.2} has increased"
		},
		'positive_negative'{
			"{name.1} has increased but {name.2} has decreased"
		},
		'negative_negative': {
			"{name.1} and {name.2} has decreased"
		},
		'positive_positive_positive': {
			"{name.1}, {name.2} and {name.3} has increased"
		}
	}
	'price': {
		'positive_positive': {
			"{name.1} and {name.2} has increased"
		},
		'positive_negative'{
			"{name.1} has increased but {name.2} has decreased"
		},
		'negative_negative': {
			"{name.1} and {name.2} has decreased"
		},
		'positive_positive_positive': {
			"{name.1}, {name.2} and {name.3} has increased"
		}
	}
}

/*
generate
[{title*
oldData*
newData
always_show}]

buildSentence
[{title*
dataFormat*
oldData*
newData
level (-3,-2,-1,0,1,2,3)
type (positive, negative, neutral)
displayInfo
group*}]

TODO
- build compound sentence by difference combination of levels?
- 'No oldData' case
- full, medium, short sentences
- display format is not in the same as the input format (e.g. input: 2.50, display: 2.5 baht)
*/