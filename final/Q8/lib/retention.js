"use strict";

const _ = require('underscore');
const async = require('async');
const dateUtils = require('./date-utils');

// Constants
const DATE_FUNCTIONS = {
    day: [ dateUtils.diaryDate, dateUtils.nextDay ],
   week: [ dateUtils.diaryWeek, dateUtils.nextWeek ],
  month: [ dateUtils.diaryMonth, dateUtils.nextMonth ],
   year: [ dateUtils.diaryYear, dateUtils.nextYear ]
};

class Retention {

  constructor(period, sections, init, then, start) {
    this._data = {};
  	this._sections = sections;
  	this._period = period;
  	this._init = init;
  	this._then = then;
    this._start = start;
  }

  get data() { return this._data; }
  get sections() { return this._sections; }
  get period() { return this._period; }
  get init() { return this._init; }
  get then() { return this._then; }
  get start() { return this._start; }

  generate(next) {
  	let period = this.period;
  	let sections = this.sections;
  	let data = this.data;

  	// build data
  	async.timesSeries(sections, (section, next) => {
  		let query = this.initDateQuery(period, section);
  		let sectionDate = this.sectionDate(period, section);
  		this.init(query, function(err, ids){
  			data[section] = [{
  				count: ids.length,
  				ids: ids,
  				date: sectionDate
  			}];
  			next();
  		});
  	}, () => {
  		async.timesSeries(sections, (section, next) => {
  			async.timesSeries(section + 1, (slot, next) => {
          let init = data[section][0];
  				let query = this.thenDateQuery(init.date, period, slot + 1);
  				let ids = init.ids;
  				this.then(query, (err, rids) => {
            rids = _.intersection(rids, ids);
            data[section].push({
  						query: query,
  						count: rids.length,
  						ids: rids,
  						percentage: (rids.length / ids.length) * 100
  					});
  					next();
  				});
  			}, next);
  		}, () => {
  			next(null, this);
  		});
  	});
  }

  print() {
  	let result = '';

  	let initLine = [ this.period, 'initial' ];
  	for (let i = 1; i <= this.sections; i++) {
  		initLine.push(i + ' ' + this.period);
  	}
  	result += initLine.join(',') + '\n';

  	for (let i2 = this.sections; i2 > 0; i2--) {
  		let sec = this.data[i2-1];
  		let date = dateUtils.excelDateFormat(sec[0].date);
  		let line = [ date, sec[0].count ];
  		for (let x = 1; x < sec.length; x++) {
  			let point = sec[x];
  			let val = isNaN(point.percentage) ? 0.0 : point.percentage;
  			line.push(val.toFixed(1) + "%");
  		}
  		result += line.join(',') + '\n';
  	}

  	return result.trim();
  }

  initDateQuery(period, section) {
  	let getDate = DATE_FUNCTIONS[period][0];
  	let getNextDate = DATE_FUNCTIONS[period][1];

  	let now = getDate.call(dateUtils, this.start);
  	let lt = getNextDate.call(dateUtils, now, -(section + 0));
  	let gte = getNextDate.call(dateUtils, now, -(section + 1));

    return {
      created: {
        $gte: gte,
        $lt: lt
      }
  	};
  }

  thenDateQuery(date, period, section) {
  	let getNextDate = DATE_FUNCTIONS[period][1];

    let gte = getNextDate.call(dateUtils, date, section);
  	let lt = getNextDate.call(dateUtils, date, section + 1);

    return {
      created: {
        $gte: gte,
        $lt: lt
      }
  	};
  }

  sectionDate(period, section) {
  	let getDate = DATE_FUNCTIONS[period][0];
  	let getNextDate = DATE_FUNCTIONS[period][1];
  	let now = getDate.call(dateUtils, this.start);
  	return getNextDate.call(dateUtils, now, -(section + 1));
  }
}

/*============================================================================*
 * Expose                                                                     *
 *============================================================================*/

exports = module.exports = Retention;

/*============================================================================*
 * Static                                                                     *
 *============================================================================*/

exports.generate = (period, sections, init, then, next) => {
	let ret = new Retention(period, sections, init, then);
	ret.generate(next);
	return ret;
};
