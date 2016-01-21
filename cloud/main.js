(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var accounting = require('accounting')
var ____Class3W=Parse.Object;for(var ____Class3W____Key in ____Class3W){if(____Class3W.hasOwnProperty(____Class3W____Key)){Lien[____Class3W____Key]=____Class3W[____Class3W____Key];}}var ____SuperProtoOf____Class3W=____Class3W===null?null:____Class3W.prototype;Lien.prototype=Object.create(____SuperProtoOf____Class3W);Lien.prototype.constructor=Lien;Lien.__superConstructor__=____Class3W;
  function Lien() {"use strict";
    // Pass the ClassName to the Parse.Object constructor
    ____Class3W.call(this,'Lien');
    // All other initialization
  }

  Object.defineProperty(Lien.prototype,"hasSuperHumanStrength",{writable:true,configurable:true,value:function() {"use strict";
    return this.get('strength') > 18;
  }});

  Object.defineProperty(Lien.prototype,"flat_rate",{writable:true,configurable:true,value:function() {"use strict";
    //If redeem within 10 days then 0
    if (this.redeem_in_10()) {
      return 0
    }
    var cert_fv = this.get('cert_fv')
    var rate = 0.06 //If fv >=1000
    if ( cert_fv < 5000) {
      rate = 0.02
    } else if (cert_fv >= 5000 && cert_fv < 10000) {
      rate = 0.04
    }
    return accounting.unformat(cert_fv * rate)
  }});

  Object.defineProperty(Lien.prototype,"redeem_in_10",{writable:true,configurable:true,value:function() {"use strict";
    return this.redeem_days() < 10 && this.get('redemption_date')
  }});

  Object.defineProperty(Lien.prototype,"total_cash_out",{writable:true,configurable:true,value:function() {"use strict";
    var cert_fv = this.get('cert_fv')
    var premium = this.get('premium')
    var recording_fee = this.get('recording_fee')
    var subs_paid = this.get('subs').reduce(function(total, sub){
      return total+sub.get('amount')
    }, 0)
    return cert_fv+premium+recording_fee+subs_paid
  }});
  //TODO: What is YEP
  Object.defineProperty(Lien.prototype,"total_interest_due",{writable:true,configurable:true,value:function() {"use strict";
    return this.flat_rate()  + this.cert_interest() + this.sub_interest()
  }});
  Object.defineProperty(Lien.prototype,"expected_amount",{writable:true,configurable:true,value:function() {"use strict";
    return this.total_cash_out()  + this.total_interest_due() + this.get('search_fee')
  }});
  Object.defineProperty(Lien.prototype,"total_check",{writable:true,configurable:true,value:function() {"use strict";
    return this.get('checks').reduce(function(total, check) {
      return total + check.get('check_amount')
    }, 0)
  }});
  Object.defineProperty(Lien.prototype,"diff",{writable:true,configurable:true,value:function() {"use strict";
    return this.expected_amount() -this.total_check()
  }});

  Object.defineProperty(Lien.prototype,"sub_interest",{writable:true,configurable:true,value:function() {"use strict";
    return this.get('subs').reduce(function(total, sub)  {
      return total + sub.interest()
    }, 0)
  }});
  // Flat Rate + Certificate Interest + Sub Interest + YEP Interest


  Object.defineProperty(Lien.prototype,"redeem_days",{writable:true,configurable:true,value:function(date) {"use strict";
    if(!date) {
      date = moment(this.get('sale_date'))
    } else {
      moment(date)
    }

    if (!this.get('redemption_date')) {
      return 0
    }
    var redemption_date = moment(this.get('redemption_date'))
    var duration = moment.duration(redemption_date.diff(date));
    var days = duration.asDays();
    return Math.round(days)
  }});

  Object.defineProperty(Lien.prototype,"cert_interest",{writable:true,configurable:true,value:function() {"use strict";
    if (!this.get('redemption_date')) {
      return
    }
    var days = this.redeem_days()

    var interest_rate = this.get('winning_bid')/100

    var int =  (days / 365) * interest_rate * this.get('cert_fv')
    return int
  }});

  Object.defineProperty(Lien.prototype,"total_subs_before_sub",{writable:true,configurable:true,value:function(sub) {"use strict";
    var base_date = moment(sub.get('date'))

    var subs = this.get('subs')
    var total = subs.reduce(function(prev, curr){
      var sub_date = moment(curr.get('date'))
      if(base_date < sub_date) {
        prev = prev + curr.get('amount')
      }
      return prev
    }, 0)
    return total
    //How do we handle tie breakers
  }});

  Object.defineProperty(Lien,"init_from_json",{writable:true,configurable:true,value:function(data) {"use strict";
    var lien = new Lien(data.general);
    var info = data.general

    info = JSON.parse(JSON.stringify(info), ( function(k,v)  {
        var number_types = ['assessed_value', 'tax_amount', 'cert_fv', 'winning_bid', 'premium', 'total_paid', 'recording_fee', 'search_fee', 'flat_rate', 'cert_int']
        var date_types = ['sale_date', 'recording_date', 'redemption_date', ]
        var calc_types = ['redemption_amt', 'total_cash_out', 'total_int_due', 'mz_check']
        if(number_types.includes(k)){
          return accounting.unformat(info[k], ".")
        }else if(date_types.includes(k)) {
          if( !info[k]){
            return undefined
          }else{
            return new Date(info[k])
          }
        }else if(calc_types.includes(k)) {
          return ""
        } else {
           return v
        }
      })
    )
    Object.keys(info).map ( function(key)
      {return lien.set(key,info[key]);}
    )
    return lien.save().then(function(lien) {
      lien.set('subs', data.subs.map( function(sub)  {return LienSub.init_from_json(lien, sub);}) )
      lien.set('checks', data.checks.map( function(check)  {return LienCheck.init_from_json(lien, check);}) )
      lien.set('annotations', data.annotations.map( function(note)  {return LienNote.init_from_json(lien, note);}) )

      return lien.save();
    }).fail(function(error) {
      lien.error = error
      return lien
    })

  }});


var ____Class3X=Parse.Object;for(var ____Class3X____Key in ____Class3X){if(____Class3X.hasOwnProperty(____Class3X____Key)){LienCheck[____Class3X____Key]=____Class3X[____Class3X____Key];}}var ____SuperProtoOf____Class3X=____Class3X===null?null:____Class3X.prototype;LienCheck.prototype=Object.create(____SuperProtoOf____Class3X);LienCheck.prototype.constructor=LienCheck;LienCheck.__superConstructor__=____Class3X;
  function LienCheck() {"use strict";
    ____Class3X.call(this,'LienCheck');
  }
  Object.defineProperty(LienCheck,"init_from_json",{writable:true,configurable:true,value:function(lien, data) {"use strict";
    var check = new LienCheck()
    check.set("lien", lien);

    data = JSON.parse(JSON.stringify(data), ( function(k,v)  {
        var number_types = ['check_amount']
        var date_types = ['check_date', 'deposit_date']
        var calc_types = ['check_interest', 'check_principal', 'dif']
        if(number_types.includes(k)){
          return accounting.unformat(data[k], ".")
        }else if(date_types.includes(k)) {
          return new Date(data[k])
        }else if(calc_types.includes(k)) {
          return ""
        } else {
           return v
        }
      })
    )

    Object.keys(data).map ( function(key)
      {return check.set(key,data[key]);}
    )

    return check
  }});

var ____Class3Y=Parse.Object;for(var ____Class3Y____Key in ____Class3Y){if(____Class3Y.hasOwnProperty(____Class3Y____Key)){LienSub[____Class3Y____Key]=____Class3Y[____Class3Y____Key];}}var ____SuperProtoOf____Class3Y=____Class3Y===null?null:____Class3Y.prototype;LienSub.prototype=Object.create(____SuperProtoOf____Class3Y);LienSub.prototype.constructor=LienSub;LienSub.__superConstructor__=____Class3Y;
  function LienSub() {"use strict";
    ____Class3Y.call(this,'LienSub');
  }

  Object.defineProperty(LienSub.prototype,"interest",{writable:true,configurable:true,value:function() {"use strict";
    var lien = this.get('lien')
    var sub_total_before = lien.total_subs_before_sub(this)
    var cert_fv = lien.get('cert_fv')
    var sub_amount = this.get('amount')

    var interest = 0
    var days = lien.redeem_days(this.get('sub_date'))


    if (sub_total_before + cert_fv >= 1500) {
      interest = this.get('amount') * (days/365) * 0.18
    } else {
      if (sub_total_before + cert_fv + sub_amount <= 1500) {
        interest = this.get('amount') * (days/365) * 0.08
      } else {
        var low_interest = 1500 - (cert_fv + sub_amount)
        var high_interst = sub_amount - low_interest

        interest = low_interest * (days/365) * 0.08 + high_interst * (days/365) * 0.18
      }
    }

    return interest
  }});
  Object.defineProperty(LienSub,"init_from_json",{writable:true,configurable:true,value:function(lien, data) {"use strict";
    var sub = new LienSub()
    sub.set("lien", lien);

    data = JSON.parse(JSON.stringify(data), ( function(k,v)  {
        var number_types = ['check_amount']
        var date_types = ['sub_date', 'check_date']
        var calc_types = ['interest']
        if(number_types.includes(k)){
          return accounting.unformat(data[k], ".")
        }else if(date_types.includes(k)) {
          return new Date(data[k])
        }else if(calc_types.includes(k)) {
          return ""
        } else {
           return v
        }
      })
    )

    Object.keys(data).map ( function(key)
      {return sub.set(key,data[key]);}
    )

    return sub
  }});

var ____Class3Z=Parse.Object;for(var ____Class3Z____Key in ____Class3Z){if(____Class3Z.hasOwnProperty(____Class3Z____Key)){LienNote[____Class3Z____Key]=____Class3Z[____Class3Z____Key];}}var ____SuperProtoOf____Class3Z=____Class3Z===null?null:____Class3Z.prototype;LienNote.prototype=Object.create(____SuperProtoOf____Class3Z);LienNote.prototype.constructor=LienNote;LienNote.__superConstructor__=____Class3Z;
  function LienNote() {"use strict";
    ____Class3Z.call(this,'LienNote');
  }
  Object.defineProperty(LienNote,"init_from_json",{writable:true,configurable:true,value:function(lien, data) {"use strict";
    var note = new LienNote()
    note.set("lien", lien);
    return note
  }});


// After specifying the Lien subclass...
Parse.Object.registerSubclass('Lien', Lien);
Parse.Object.registerSubclass('LienCheck', LienCheck);
Parse.Object.registerSubclass('LienSub', LienSub);
Parse.Object.registerSubclass('LienNote', LienNote);

module.exports = Lien

},{"accounting":3}],2:[function(require,module,exports){
var Lien;

Lien = require('./classes/lien.js');

Parse.Cloud.define('hello', function(request, response) {
  response.success('Hello world!');
});

Parse.Cloud.beforeSave('Lien', function(request, response) {
  var query;
  if (request.object.isNew()) {
    query = new Parse.Query('Lien');
    query.equalTo('unique_id', request.object.get('unique_id'));
    query.find().then(function(liens) {
      if (liens.length === 0) {
        return response.success();
      } else {
        return response.error("Lien already created with this unique_id");
      }
    });
  } else {
    response.success();
  }
});

},{"./classes/lien.js":1}],3:[function(require,module,exports){
/*!
 * accounting.js v0.4.1
 * Copyright 2014 Open Exchange Rates
 *
 * Freely distributable under the MIT license.
 * Portions of accounting.js are inspired or borrowed from underscore.js
 *
 * Full details and documentation:
 * http://openexchangerates.github.io/accounting.js/
 */

(function(root, undefined) {

	/* --- Setup --- */

	// Create the local library object, to be exported or referenced globally later
	var lib = {};

	// Current version
	lib.version = '0.4.1';


	/* --- Exposed settings --- */

	// The library's settings configuration object. Contains default parameters for
	// currency and number formatting
	lib.settings = {
		currency: {
			symbol : "$",		// default currency symbol is '$'
			format : "%s%v",	// controls output: %s = symbol, %v = value (can be object, see docs)
			decimal : ".",		// decimal point separator
			thousand : ",",		// thousands separator
			precision : 2,		// decimal places
			grouping : 3		// digit grouping (not implemented yet)
		},
		number: {
			precision : 0,		// default precision on numbers is 0
			grouping : 3,		// digit grouping (not implemented yet)
			thousand : ",",
			decimal : "."
		}
	};


	/* --- Internal Helper Methods --- */

	// Store reference to possibly-available ECMAScript 5 methods for later
	var nativeMap = Array.prototype.map,
		nativeIsArray = Array.isArray,
		toString = Object.prototype.toString;

	/**
	 * Tests whether supplied parameter is a string
	 * from underscore.js
	 */
	function isString(obj) {
		return !!(obj === '' || (obj && obj.charCodeAt && obj.substr));
	}

	/**
	 * Tests whether supplied parameter is a string
	 * from underscore.js, delegates to ECMA5's native Array.isArray
	 */
	function isArray(obj) {
		return nativeIsArray ? nativeIsArray(obj) : toString.call(obj) === '[object Array]';
	}

	/**
	 * Tests whether supplied parameter is a true object
	 */
	function isObject(obj) {
		return obj && toString.call(obj) === '[object Object]';
	}

	/**
	 * Extends an object with a defaults object, similar to underscore's _.defaults
	 *
	 * Used for abstracting parameter handling from API methods
	 */
	function defaults(object, defs) {
		var key;
		object = object || {};
		defs = defs || {};
		// Iterate over object non-prototype properties:
		for (key in defs) {
			if (defs.hasOwnProperty(key)) {
				// Replace values with defaults only if undefined (allow empty/zero values):
				if (object[key] == null) object[key] = defs[key];
			}
		}
		return object;
	}

	/**
	 * Implementation of `Array.map()` for iteration loops
	 *
	 * Returns a new Array as a result of calling `iterator` on each array value.
	 * Defers to native Array.map if available
	 */
	function map(obj, iterator, context) {
		var results = [], i, j;

		if (!obj) return results;

		// Use native .map method if it exists:
		if (nativeMap && obj.map === nativeMap) return obj.map(iterator, context);

		// Fallback for native .map:
		for (i = 0, j = obj.length; i < j; i++ ) {
			results[i] = iterator.call(context, obj[i], i, obj);
		}
		return results;
	}

	/**
	 * Check and normalise the value of precision (must be positive integer)
	 */
	function checkPrecision(val, base) {
		val = Math.round(Math.abs(val));
		return isNaN(val)? base : val;
	}


	/**
	 * Parses a format string or object and returns format obj for use in rendering
	 *
	 * `format` is either a string with the default (positive) format, or object
	 * containing `pos` (required), `neg` and `zero` values (or a function returning
	 * either a string or object)
	 *
	 * Either string or format.pos must contain "%v" (value) to be valid
	 */
	function checkCurrencyFormat(format) {
		var defaults = lib.settings.currency.format;

		// Allow function as format parameter (should return string or object):
		if ( typeof format === "function" ) format = format();

		// Format can be a string, in which case `value` ("%v") must be present:
		if ( isString( format ) && format.match("%v") ) {

			// Create and return positive, negative and zero formats:
			return {
				pos : format,
				neg : format.replace("-", "").replace("%v", "-%v"),
				zero : format
			};

		// If no format, or object is missing valid positive value, use defaults:
		} else if ( !format || !format.pos || !format.pos.match("%v") ) {

			// If defaults is a string, casts it to an object for faster checking next time:
			return ( !isString( defaults ) ) ? defaults : lib.settings.currency.format = {
				pos : defaults,
				neg : defaults.replace("%v", "-%v"),
				zero : defaults
			};

		}
		// Otherwise, assume format was fine:
		return format;
	}


	/* --- API Methods --- */

	/**
	 * Takes a string/array of strings, removes all formatting/cruft and returns the raw float value
	 * Alias: `accounting.parse(string)`
	 *
	 * Decimal must be included in the regular expression to match floats (defaults to
	 * accounting.settings.number.decimal), so if the number uses a non-standard decimal 
	 * separator, provide it as the second argument.
	 *
	 * Also matches bracketed negatives (eg. "$ (1.99)" => -1.99)
	 *
	 * Doesn't throw any errors (`NaN`s become 0) but this may change in future
	 */
	var unformat = lib.unformat = lib.parse = function(value, decimal) {
		// Recursively unformat arrays:
		if (isArray(value)) {
			return map(value, function(val) {
				return unformat(val, decimal);
			});
		}

		// Fails silently (need decent errors):
		value = value || 0;

		// Return the value as-is if it's already a number:
		if (typeof value === "number") return value;

		// Default decimal point comes from settings, but could be set to eg. "," in opts:
		decimal = decimal || lib.settings.number.decimal;

		 // Build regex to strip out everything except digits, decimal point and minus sign:
		var regex = new RegExp("[^0-9-" + decimal + "]", ["g"]),
			unformatted = parseFloat(
				("" + value)
				.replace(/\((.*)\)/, "-$1") // replace bracketed values with negatives
				.replace(regex, '')         // strip out any cruft
				.replace(decimal, '.')      // make sure decimal point is standard
			);

		// This will fail silently which may cause trouble, let's wait and see:
		return !isNaN(unformatted) ? unformatted : 0;
	};


	/**
	 * Implementation of toFixed() that treats floats more like decimals
	 *
	 * Fixes binary rounding issues (eg. (0.615).toFixed(2) === "0.61") that present
	 * problems for accounting- and finance-related software.
	 */
	var toFixed = lib.toFixed = function(value, precision) {
		precision = checkPrecision(precision, lib.settings.number.precision);
		var power = Math.pow(10, precision);

		// Multiply up by precision, round accurately, then divide and use native toFixed():
		return (Math.round(lib.unformat(value) * power) / power).toFixed(precision);
	};


	/**
	 * Format a number, with comma-separated thousands and custom precision/decimal places
	 * Alias: `accounting.format()`
	 *
	 * Localise by overriding the precision and thousand / decimal separators
	 * 2nd parameter `precision` can be an object matching `settings.number`
	 */
	var formatNumber = lib.formatNumber = lib.format = function(number, precision, thousand, decimal) {
		// Resursively format arrays:
		if (isArray(number)) {
			return map(number, function(val) {
				return formatNumber(val, precision, thousand, decimal);
			});
		}

		// Clean up number:
		number = unformat(number);

		// Build options object from second param (if object) or all params, extending defaults:
		var opts = defaults(
				(isObject(precision) ? precision : {
					precision : precision,
					thousand : thousand,
					decimal : decimal
				}),
				lib.settings.number
			),

			// Clean up precision
			usePrecision = checkPrecision(opts.precision),

			// Do some calc:
			negative = number < 0 ? "-" : "",
			base = parseInt(toFixed(Math.abs(number || 0), usePrecision), 10) + "",
			mod = base.length > 3 ? base.length % 3 : 0;

		// Format the number:
		return negative + (mod ? base.substr(0, mod) + opts.thousand : "") + base.substr(mod).replace(/(\d{3})(?=\d)/g, "$1" + opts.thousand) + (usePrecision ? opts.decimal + toFixed(Math.abs(number), usePrecision).split('.')[1] : "");
	};


	/**
	 * Format a number into currency
	 *
	 * Usage: accounting.formatMoney(number, symbol, precision, thousandsSep, decimalSep, format)
	 * defaults: (0, "$", 2, ",", ".", "%s%v")
	 *
	 * Localise by overriding the symbol, precision, thousand / decimal separators and format
	 * Second param can be an object matching `settings.currency` which is the easiest way.
	 *
	 * To do: tidy up the parameters
	 */
	var formatMoney = lib.formatMoney = function(number, symbol, precision, thousand, decimal, format) {
		// Resursively format arrays:
		if (isArray(number)) {
			return map(number, function(val){
				return formatMoney(val, symbol, precision, thousand, decimal, format);
			});
		}

		// Clean up number:
		number = unformat(number);

		// Build options object from second param (if object) or all params, extending defaults:
		var opts = defaults(
				(isObject(symbol) ? symbol : {
					symbol : symbol,
					precision : precision,
					thousand : thousand,
					decimal : decimal,
					format : format
				}),
				lib.settings.currency
			),

			// Check format (returns object with pos, neg and zero):
			formats = checkCurrencyFormat(opts.format),

			// Choose which format to use for this value:
			useFormat = number > 0 ? formats.pos : number < 0 ? formats.neg : formats.zero;

		// Return with currency symbol added:
		return useFormat.replace('%s', opts.symbol).replace('%v', formatNumber(Math.abs(number), checkPrecision(opts.precision), opts.thousand, opts.decimal));
	};


	/**
	 * Format a list of numbers into an accounting column, padding with whitespace
	 * to line up currency symbols, thousand separators and decimals places
	 *
	 * List should be an array of numbers
	 * Second parameter can be an object containing keys that match the params
	 *
	 * Returns array of accouting-formatted number strings of same length
	 *
	 * NB: `white-space:pre` CSS rule is required on the list container to prevent
	 * browsers from collapsing the whitespace in the output strings.
	 */
	lib.formatColumn = function(list, symbol, precision, thousand, decimal, format) {
		if (!list) return [];

		// Build options object from second param (if object) or all params, extending defaults:
		var opts = defaults(
				(isObject(symbol) ? symbol : {
					symbol : symbol,
					precision : precision,
					thousand : thousand,
					decimal : decimal,
					format : format
				}),
				lib.settings.currency
			),

			// Check format (returns object with pos, neg and zero), only need pos for now:
			formats = checkCurrencyFormat(opts.format),

			// Whether to pad at start of string or after currency symbol:
			padAfterSymbol = formats.pos.indexOf("%s") < formats.pos.indexOf("%v") ? true : false,

			// Store value for the length of the longest string in the column:
			maxLength = 0,

			// Format the list according to options, store the length of the longest string:
			formatted = map(list, function(val, i) {
				if (isArray(val)) {
					// Recursively format columns if list is a multi-dimensional array:
					return lib.formatColumn(val, opts);
				} else {
					// Clean up the value
					val = unformat(val);

					// Choose which format to use for this value (pos, neg or zero):
					var useFormat = val > 0 ? formats.pos : val < 0 ? formats.neg : formats.zero,

						// Format this value, push into formatted list and save the length:
						fVal = useFormat.replace('%s', opts.symbol).replace('%v', formatNumber(Math.abs(val), checkPrecision(opts.precision), opts.thousand, opts.decimal));

					if (fVal.length > maxLength) maxLength = fVal.length;
					return fVal;
				}
			});

		// Pad each number in the list and send back the column of numbers:
		return map(formatted, function(val, i) {
			// Only if this is a string (not a nested array, which would have already been padded):
			if (isString(val) && val.length < maxLength) {
				// Depending on symbol position, pad after symbol or at index 0:
				return padAfterSymbol ? val.replace(opts.symbol, opts.symbol+(new Array(maxLength - val.length + 1).join(" "))) : (new Array(maxLength - val.length + 1).join(" ")) + val;
			}
			return val;
		});
	};


	/* --- Module Definition --- */

	// Export accounting for CommonJS. If being loaded as an AMD module, define it as such.
	// Otherwise, just add `accounting` to the global object
	if (typeof exports !== 'undefined') {
		if (typeof module !== 'undefined' && module.exports) {
			exports = module.exports = lib;
		}
		exports.accounting = lib;
	} else if (typeof define === 'function' && define.amd) {
		// Return the library as an AMD module:
		define([], function() {
			return lib;
		});
	} else {
		// Use accounting.noConflict to restore `accounting` back to its original value.
		// Returns a reference to the library's `accounting` object;
		// e.g. `var numbers = accounting.noConflict();`
		lib.noConflict = (function(oldAccounting) {
			return function() {
				// Reset the value of the root's `accounting` variable:
				root.accounting = oldAccounting;
				// Delete the noConflict method:
				lib.noConflict = undefined;
				// Return reference to the library to re-assign it:
				return lib;
			};
		})(root.accounting);

		// Declare `fx` on the root (global/window) object:
		root['accounting'] = lib;
	}

	// Root will be `window` in browser or `global` on the server:
}(this));

},{}]},{},[2]);
