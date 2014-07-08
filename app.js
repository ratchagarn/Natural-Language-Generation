var _ = require('underscore');
var oldData = require('./old.json');
var newData = require('./new.json');
var words = require('./words.json');
var settings = require('./settings.json');
var sentences = require('./sentences.json');
require('coffee-script');
var JittaData = require('./JittaData');


function getUpdates(oldData, newData){
	var updatedData = {
		jitta: [],
		quantitative: [],
		qualitative: []
	};
	for(type in oldData){
		for(key in oldData[type]){
			if(settings[type][key]['always_show'] || oldData[type][key] != newData[type][key]){
				var obj = {
					data: {
						name: key,
						oldData: oldData[type][key],
						newData: newData[type][key]
					},
					priority: settings[type][key]['priority'],
				};
				if(type == 'quantitative' || type == 'jitta'){
					obj.max = settings[type][key]['max'];
					obj.min = settings[type][key]['min'];
					obj.sensitiveness = settings[type][key]['sensitiveness'];
				}
				updatedData[type].push(obj);
			}
		}
		updatedData[type] = _.sortBy(updatedData[type], function(i){ return i.priority; });
	}
	// console.log(updatedData);
	return updatedData;
}

function buildSentences(updates){
	var listOfSentences = {
		jitta: buildJittaSentences(updates.jitta),
		quantitative: buildQuantitativeSentences(updates.quantitative),
		qualitative: buildQualitativeSentences(updates.qualitative)
	};
	return listOfSentences;
}

function buildJittaSentences(jittaUpdates){
	var listOfSentences = [];
	for(i in jittaUpdates){
		var oldValue = jittaUpdates[i].data.oldData;
		var newValue = jittaUpdates[i].data.newData;
		var sentence = null;
		if(jittaUpdates[i].data.name == 'Jitta Line'){
			sentence = buildJittaLineSentence(jittaUpdates[i]);
		}
		else if(jittaUpdates[i].data.name == 'Price'){
			var boundedDiff = ((newValue-oldValue)*100)/oldValue;
			var percentChanged = Math.abs(((newValue-oldValue)*100)/oldValue).toFixed(2)+'%';
			jittaUpdates[i].data.difference = percentChanged;
			sentence = buildQuantitativeSentence(boundedDiff, sentences.quantitative, jittaUpdates[i]);
		}

		// Build the sentence from data and push to the output array
		if(sentence)
			listOfSentences.push(sentence);
	}
	return listOfSentences;
}

function buildJittaLineSentence(jittaUpdate){
	var oldValue               = jittaUpdate.data.oldData;
	var newValue               = jittaUpdate.data.newData;
	var oldPercentIndex        = oldValue.indexOf('%');
	var oldStatus              = oldValue.substring(oldPercentIndex+2, oldPercentIndex+7);
	var newPercentIndex        = newValue.indexOf('%');
	var newStatus              = newValue.substring(newPercentIndex+2, newPercentIndex+7);
	var index                  = oldStatus + '_' + newStatus;
	var newNumber              = newValue.substring(0,newPercentIndex);
	var oldNumber              = oldValue.substring(0,oldPercentIndex);
	if(newStatus == 'Below')
		newNumber = newNumber * -1;
	if(oldStatus == 'Below')
		oldNumber = oldNumber * -1;
	var diff = oldNumber - newNumber;
	jittaUpdate.data.oldNumber = oldValue.substring(0,oldPercentIndex);
	jittaUpdate.data.newNumber = newValue.substring(0,newPercentIndex);
	return replaceStr(sentences.jitta[index][degree], jittaUpdate.data);
}

function buildQuantitativeSentences(quantitativeUpdates){
	var listOfSentences = [];
	for(i in quantitativeUpdates){

		// Find the value difference
		var diff = quantitativeUpdates[i].data.newData - quantitativeUpdates[i].data.oldData;

		// Push the difference value into the list
		quantitativeUpdates[i].data.difference = Math.abs(diff).toFixed(2);

		// Find difference value that is between -1 to 1
		var boundedDiff = getBoundedDifference(quantitativeUpdates[i]);

		// Build the sentence from data and push to the output array
		var sentence = buildQuantitativeSentence(boundedDiff, sentences.quantitative, quantitativeUpdates[i]);
		listOfSentences.push(sentence);
	}
	return listOfSentences;
}

function getBoundedDifference(quantitativeUpdate){
	// Find the value difference
	var diff = quantitativeUpdate.data.newData - quantitativeUpdate.data.oldData;

	// Bound the difference value between -1 to 1
	var boundedDiff = diff/(quantitativeUpdate.max - quantitativeUpdate.min);

	return boundedDiff;
}

function buildQualitativeSentences(qualitativeUpdates){
	// console.log(qualitativeUpdates);
	var listOfSentences = [];
	for(i in qualitativeUpdates){
		if(qualitativeUpdates[i].data.newData == qualitativeUpdates[i].data.oldData && 
			qualitativeUpdates[i].data.newData != null){
			listOfSentences.push(replaceStr(sentences.qualitative['0'], qualitativeUpdates[i].data));
		}
		else if(qualitativeUpdates[i].data.newData != null){
		// else if(qualitativeUpdates[i].data.oldData == null && 
		// 	qualitativeUpdates[i].data.newData != null){
			var score = scoreData(qualitativeUpdates[i].data.newData);
			console.log(qualitativeUpdates[i].data.newData+" "+score);
			listOfSentences.push(replaceStr(sentences.qualitative[score], qualitativeUpdates[i].data));
		}
	}
	return listOfSentences;
}

function scoreData(text){
	var textObj = _.findWhere(words.words, {word: text});
	if(textObj)
		return textObj.score;
	else
		return '0';
}

function buildQuantitativeSentence(boundedDiff, listOfSentences, update){
	var scale = update.sensitiveness/4;
	var level = null;
	if(boundedDiff > 0){
		level = Math.ceil(boundedDiff/scale);
		if(level > 5) level = 5;
	}
	else{
		level = Math.floor(boundedDiff/scale);
		if(level < -5) level = -5;
	}
	var index = level.toString();
	// console.log(boundedDiff+ " "+level);
	return replaceStr(listOfSentences[index], update.data);
}

function replaceStr(patterns, data){
	var pattern = _.sample(patterns);
	for(key in data){
		pattern = pattern.replace('{'+key+'}', data[key]);
	}
	return pattern;
}

// getUpdates(oldData,newData);
// buildSentences(getUpdates(oldData,newData));
// var out = buildSentences(getUpdates(oldData,newData));
// console.log(out);