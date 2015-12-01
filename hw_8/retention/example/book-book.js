"use strict";

// Require our retention lib
const retention = require('./lib/retention');

// Sudo reference, pretend this is a MongoDB colletion
// that contains booking reservations
const Booking = require('modules/booking').model;

/**
 * Find initial set of users who booked a table
 *
 * @method initIds
 * @param {Object} query - base query created by retention lib
 * @param {Function} next - callback when complete
 */
function initIds(query, next) {
  query.status = 'PROCESSED';

	Booking.distinct('userId', query, next);
}

/**
 * Find retained users based on passed in query
 *
 * @method retainedIds
 * @param {Object} query - base query created by retention lib
 * @param [String] ids - array of ids to retain
 * @param {Function} next - callback when complete
 */
function retainedIds(query, ids, next) {
	query.userId = { $in: ids };
	query.status = 'PROCESSED';

	Booking.distinct('userId', query, next);
}

/**
 * Generate retention and print to stdout
 *
 * @method retainedIds
 * @param {Function} next - callback when complete
 */
function generate(next) {
	let period = 'month';
	let sections = 12;
	retention.generate(period, sections, initIds, retainedIds, function(err, ret){
		console.log(ret.print());
		next();
	});
}

generate();
