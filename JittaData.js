var _ = require('underscore');
var words = require('./words.json');
var settings = require('./settings.json');
var sentences = require('./sentences.json');

var JittaData = function(name, oldData, newData){
	this.name = name;
	this.oldData = this.makeData(oldData);
	this.newData = this.makeData(newData);
};

JittaData.prototype = {
	constructor: JittaData,
	buildSentence: function(){
	},
	replaceStr: function(patterns, data){
		var pattern = _.sample(patterns);
		for(key in data){
			pattern = pattern.replace('{'+key+'}', data[key]);
		}
		return pattern;
	},
	makeData: function(data){
		return data;
	},

}

module.exports = JittaData;