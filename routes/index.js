/**
 * Module dependencies
 */
var express = require('express');

/**
 * the new Router exposed in express 4
 * the indexRouter handles all requests to the `/` path
 */
var indexRouter = express.Router();

/**
 * this accepts all request methods to the `/` path
 */

indexRouter.route('/products')

indexRouter.route('/*')
  .all(function(req, res) {
    res.render('grid');
  })
exports.indexRouter = indexRouter;
