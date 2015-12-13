'use strict';

const _ = require('underscore');
const fs = require('fs');
const dateUtils = require('./lib/date-utils');
const Retention = require('./lib/retention');

const PERIOD = 'day';

// read in csv file
fs.readFile('./Miley.Nicki.Taylor.csv', (err, data) => {
  if (err) throw err;

  // parse lines
  let tweets = _
    .chain(data.toString('utf8').split('\n'))
    .map(line => {
      let tweet = line.split(',');
      return {
        user: tweet[0],
        date: dateUtils.diaryDate(new Date(tweet[1])),
        text: tweet.slice(2).join(',')
      };
    })
    .groupBy('date')
    .value();

  // generate retention
  let retention = new Retention(PERIOD, 30, initIds, retainedIds, new Date('2015-12-5'));
  retention.generate((err, ret) => {
    if (err) throw err;
    console.log(ret.print());
	});

  /**
   * Initial set of uniqe words for each day
   */
  function initIds(query, next) {
    let ids = _
      .chain(tweets[query.created.$gte])
      .filter(tweet => /bitch/gi.test(tweet.text))
      .map(tweet => tweet.text.split(' '))
      .flatten()
      .unique()
      .value();

    next(null, ids);
  }

  /**
   * Unique words for the given date, will be compared to an initial set
   */
  function retainedIds(query, next) {
    let ids = _
      .chain(tweets[query.created.$gte])
      .map(tweet => tweet.text.split(' '))
      .flatten()
      .unique()
      .value();

    next(null, ids);
  }
});
