/*============================================================================*
 *                                                                            *
 *                                 Retention                                  *
 *                                                                            *
 *============================================================================*/

/*============================================================================*
 * Dependencies                                                               *
 *============================================================================*/

const async = require('async');
const dateUtils = require('./date-utils');

const DATE_FUNCTIONS = {
  'day'  : [ dateUtils.diaryDate, dateUtils.tomorrow ],
  'week' : [ dateUtils.diaryWeek, dateUtils.nextWeek ],
  'month': [ dateUtils.diaryMonth, dateUtils.nextMonth ],
  'year' : [ dateUtils.diaryYear, dateUtils.nextYear ],
};

/*============================================================================*
 * Service                                                                    *
 *============================================================================*/

function Retention(period, sections, init, then){
	this.data = {};
	this.sections = sections;
	this.period = period;
	this.init = init;
	this.then = then;
}

/*============================================================================*
 * Methods                                                                    *
 *============================================================================*/

Retention.prototype.generate = function(next) {
	var _this = this;
	var period = this.period;
	var sections = this.sections;
	var data = this.data;

	// build data
	async.timesSeries(sections, function(section, next){
		var query = _this.initDateQuery(period, section);
		var sectionDate = _this.sectionDate(period, section);
		_this.init(query, function(err, ids){
			data[section] = [{
				count: ids.length,
				ids: ids,
				date: sectionDate
			}];
			next();
		});
	}, function(){
		async.timesSeries(sections, function(section, next){
			async.timesSeries(section + 1, function(slot, next){
				var init = data[section][0];
				var query = _this.thenDateQuery(init.date, period, slot + 1);
				var ids = init.ids;
				_this.then(query, ids, function(err, ids){
					data[section].push({
						query: query,
						count: ids.length,
						ids: ids,
						percentage: (ids.length / init.count) * 100
					});
					next();
				});
			}, next);
		}, function(){
			next(null, _this);
		});
	});
};

Retention.prototype.print = function() {
	var result = '';

	var initLine = [ this.period, 'initial' ];
	for (var i = 1; i <= this.sections; i++) {
		initLine.push(i + ' ' + this.period);
	}
	result += initLine.join(',') + '\n';

	for (var i2 = this.sections; i2 > 0; i2--) {
		var sec = this.data[i2-1];
		var date = dateUtils.excelDateFormat(sec[0].date);
		var line = [ date, sec[0].count ];
		for (var x = 1; x < sec.length; x++) {
			var point = sec[x];
			var val = isNaN(point.percentage) ? 0.0 : point.percentage;
			line.push(val.toFixed(1) + "%");
		}
		result += line.join(',') + '\n';
	}

	return result.trim();
};

Retention.prototype.initDateQuery = function(period, section) {
	var getDate = DATE_FUNCTIONS[period][0];
	var getNextDate = DATE_FUNCTIONS[period][1];

	var now = getDate();
	var lt = getNextDate(now, -(section + 0));
	var gte = getNextDate(now, -(section + 1));

  return {
    created: {
      $gte: gte,
      $lt: lt
    }
	};
};

Retention.prototype.thenDateQuery = function(date, period, section) {
	var getNextDate = DATE_FUNCTIONS[period][1];

  var gte = getNextDate(date, section);
	var lt = getNextDate(date, section + 1);

  return {
    created: {
      $gte: gte,
      $lt: lt
    }
	};
};

Retention.prototype.sectionDate = function(period, section) {
	var getDate = DATE_FUNCTIONS[period][0];
	var getNextDate = DATE_FUNCTIONS[period][1];
	var now = getDate();
	return getNextDate(now, -(section + 1));
};

/*============================================================================*
 * Expose                                                                     *
 *============================================================================*/

exports = module.exports = Retention;

/*============================================================================*
 * Static                                                                     *
 *============================================================================*/

exports.generate = function(period, sections, init, then, next) {
	var ret = new Retention(period, sections, init, then);
	ret.generate(next);
	return ret;
};
