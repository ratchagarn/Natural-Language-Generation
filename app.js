var _ = require('underscore');
var oldData = require('./old.json');
var newData = require('./new.json');
var words = require('./words.json');
var settings = require('./settings.json');
var sentences = require('./sentences.json');

function getUpdates(oldData, newData){
	var updatedData = {
		jitta: [],
		quantitative: [],
		qualitative: []
	};
	for(type in oldData){
		for(key in oldData[type]){
			if((oldData[type][key] != newData[type][key]) && 
				(type == 'quantitative' || type == 'jitta')){
				updatedData[type].push({
					data: {
						oldData: oldData[type][key],
						newData: newData[type][key]
					},
					type: key,
					max: settings[type][key]['max'],
					min: settings[type][key]['min'],
					priority: settings[type][key]['priority'],
					sensitiveness: settings[type][key]['sensitiveness']
				});
			}
			else if(type == 'qualitative'){
				updatedData[type].push({
					data: {
						name: key,
						oldData: oldData[type][key],
						newData: newData[type][key]
					},
					priority: settings[type][key]['priority']
				});
			}
		}
		updatedData[type] = _.sortBy(updatedData[type], function(i){ return i.priority; });
	}
	// console.log(updatedData);
	return updatedData;
}

function buildSentences(updates){
	listOfSentences = {
		jitta: buildJittaSentences(updates.jitta),
		quantitative: buildQuantitativeSentences(updates.quantitative),
		qualitative: buildQualitativeSentences(updates.qualitative)
	};
	return listOfSentences;
}

function buildJittaSentences(jittaUpdates){
	listOfSentences = [];
	for(i in jittaUpdates){
		oldValue = jittaUpdates[i].data.oldData;
		newValue = jittaUpdates[i].data.newData;
		if(jittaUpdates[i].type == 'Jitta Line'){
			// Extract the numbers
			oldPercentIndex = oldValue.indexOf('%');
			oldNumber = oldValue.substring(0,oldPercentIndex);
			newPercentIndex = newValue.indexOf('%');
			newNumber = newValue.substring(0,newPercentIndex);

			// Treat it the same as buildQuantitativeSentences(...)
			boundedDiff = (newNumber-oldNumber)/10;
			jittaUpdates[i].data.display = Math.abs(newNumber-oldNumber).toFixed(2);
		}
		else if(jittaUpdates[i].type == 'Price'){
			boundedDiff = ((newValue-oldValue)*100)/oldValue;
			percentChanged = Math.abs(((newValue-oldValue)*100)/oldValue).toFixed(2)+'%';
			jittaUpdates[i].data.difference = percentChanged;
		}

		// Add the data name to the top of the list
		jittaUpdates[i].data.name = jittaUpdates[i].type;

		// Build the sentence from data and push to the output array
		sentence = buildQuantitativeSentence(boundedDiff, sentences.quantitative, jittaUpdates[i]);
		listOfSentences.push(sentence);
	}
	return listOfSentences;
}

function buildQuantitativeSentences(quantitativeUpdates){
	listOfSentences = [];
	for(i in quantitativeUpdates){

		// Find the value difference
		diff = quantitativeUpdates[i].data.newData - quantitativeUpdates[i].data.oldData;

		// Bound the difference value between -1 to 1
		boundedDiff = diff/(quantitativeUpdates[i].max - quantitativeUpdates[i].min);

		// Push the difference value into the list
		quantitativeUpdates[i].data.difference = Math.abs(diff).toFixed(2);

		// Add the data name to the top of the list
		quantitativeUpdates[i].data.name = quantitativeUpdates[i].type;

		// Build the sentence from data and push to the output array
		sentence = buildQuantitativeSentence(boundedDiff, sentences.quantitative, quantitativeUpdates[i]);
		listOfSentences.push(sentence);
	}
	return listOfSentences;
}

function buildQualitativeSentences(qualitativeUpdates){
	// console.log(qualitativeUpdates);
	listOfSentences = [];
	for(i in qualitativeUpdates){
		if(qualitativeUpdates[i].data.newData == qualitativeUpdates[i].data.oldData && 
			qualitativeUpdates[i].data.newData != null){
			listOfSentences.push(replaceStr(sentences.qualitative['0'], qualitativeUpdates[i].data));
		}
		else if(qualitativeUpdates[i].data.newData != null){
		// else if(qualitativeUpdates[i].data.oldData == null && 
		// 	qualitativeUpdates[i].data.newData != null){
			score = scoreData(qualitativeUpdates[i].data.newData);
			console.log(qualitativeUpdates[i].data.newData+" "+score);
			listOfSentences.push(replaceStr(sentences.qualitative[score], qualitativeUpdates[i].data));
		}
	}
	return listOfSentences;
}

function scoreData(text){
	textObj = _.findWhere(words.words, {word: text});
	if(textObj)
		return textObj.score;
	else
		return '0';
}

function buildQuantitativeSentence(boundedDiff, listOfSentences, update){
	scale = update.sensitiveness/4;
	if(boundedDiff > 0){
		level = Math.ceil(boundedDiff/scale);
		if(level > 5) level = 5;
	}
	else{
		level = Math.floor(boundedDiff/scale);
		if(level < -5) level = -5;
	}
	index = level.toString();
	// console.log(boundedDiff+ " "+level);
	return replaceStr(listOfSentences[index], update.data);
}

function replaceStr(patterns, data){
	pattern = _.sample(patterns);
	for(key in data){
		pattern = pattern.replace('{'+key+'}', data[key]);
	}
	return pattern;
}

// getUpdates(oldData,newData);
// buildSentences(getUpdates(oldData,newData));
out = buildSentences(getUpdates(oldData,newData));
console.log(out);