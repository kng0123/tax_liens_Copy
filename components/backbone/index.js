var RelationalModel = require('backbone-relational')
var Backbone = require('backbone');

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

//GOTCHA Must specify full path Name or watchify wont work
global.BackboneApp = {
  Models: {},
  Collections: {}
}
require('./models/lien.js')(BackboneApp)
