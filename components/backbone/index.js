var RelationalModel = require('backbone-relational')
var Backbone = require('backbone');
Backbone.Relational.showWarnings = false
var _sync;
_sync = Backbone.sync;
Backbone.sync = function(method, model, options) {
  var token = $("meta[name='csrf-token']").attr('content');
  options.beforeSend = function(xhr) {
    xhr.setRequestHeader('Content-Type', 'application/vnd.api+json')
    return xhr.setRequestHeader("X-CSRF-Token", token);
  };
  return _sync.call(this, method, model, options);
};
//
//
// $.ajaxPrefilter(function (options, originalOptions, jqXHR) {
//   var token = $("meta[name='csrf-token']").attr('content');;
//   jqXHR.setRequestHeader('Content-Type', 'application/vnd.api+json')
//   jqXHR.setRequestHeader('X-CSRF-Token', token);
// });

//GOTCHA Must specify full path Name or watchify wont work
global.BackboneApp = {
  Models: {},
  Collections: {}
}
require('./models/lien.js')(BackboneApp)
