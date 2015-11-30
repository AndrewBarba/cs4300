"use strict";

const moment = require('moment');

class DateUtils {

  diaryDate(date, hour) {
    date = date || new Date();
    hour = hour || 6;

    // if the date is less than 6 AM then it is the day before
    // diary days run from 6 AM - 6 AM
    var subDate = (date.getHours() < hour) ? 1 : 0;

    // return a new date at 6 AM
    return new Date(date.getFullYear(), date.getMonth(), date.getDate() - subDate, hour);
  }

  tomorrow(date) {
    date = this.diaryDate(date);
    date.setDate(date.getDate() + 1);
    return date;
  }

  yesterday(date) {
    date = this.diaryDate(date);
    date.setDate(date.getDate() - 1);
    return date;
  }

  diaryWeek(date) {
    date = this.diaryDate(date);
    var sub = (date.getDay() === 0) ? 7 : date.getDay();
    date.setDate(date.getDate() - sub + 1); // starts monday for us
    return date;
  }

  nextWeek(date, num) {
    num = num === undefined ? 1 : num;
    date = this.diaryWeek(date);
    date.setDate(date.getDate() + (7 * num));
    return date;
  }

  diaryMonth(date) {
    date = this.diaryDate(date);
    date.setDate(1);
    return date;
  }

  nextMonth(date, num) {
    num = num === undefined ? 1 : num;
    date = this.diaryMonth(date);
    date.setMonth(date.getMonth() + num);
    return date;
  }

  diaryYear(date) {
    date = this.diaryMonth(date);
    date.setMonth(0);
    return date;
  }

  nextYear(date, num) {
    num = num === undefined ? 1 : num;
    date = this.diaryYear(date);
    date.setYear(date.getFullYear() + num);
    return date;
  }

  excelDateFormat(val) {
    var date = moment(val).utc();
    var returnVal = date.format("YYYY-MM-DD HH:mm:ss");
    return returnVal;
  }
}

exports = module.exports = new DateUtils();
