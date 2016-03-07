(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
Parse.Cloud.define('delete', function(request, response) {
  var query;
  query = new Parse.Query('Lien');
  query.find().then(function(liens) {
    return Parse.Object.destroyAll(liens);
  }).then(function() {
    query = new Parse.Query('LienSub');
    return query.find();
  }).then(function(subs) {
    return Parse.Object.destroyAll(subs);
  }).then(function() {
    query = new Parse.Query('LienCheck');
    return query.find();
  }).then(function(checks) {
    return Parse.Object.destroyAll(checks);
  }).then(function() {
    query = new Parse.Query('LienNote');
    return query.find();
  }).then(function(notes) {
    return Parse.Object.destroyAll(notes);
  }).then(function() {
    query = new Parse.Query('Township');
    return query.find();
  }).then(function(townships) {
    return Parse.Object.destroyAll(townships);
  }).then(function() {
    query = new Parse.Query('SubBatch');
    return query.find();
  }).then(function(batches) {
    return Parse.Object.destroyAll(batches);
  }).then(function() {
    query = new Parse.Query('LienOwner');
    return query.find();
  }).then(function(owners) {
    return Parse.Object.destroyAll(owners);
  }).then(function() {
    return response.success("success");
  }).fail(function() {
    return response.error("error");
  });
});

Parse.Cloud.beforeSave('Lien', function(request, response) {
  var query;
  if (request.object.isNew()) {
    query = new Parse.Query('Lien');
    query.equalTo('objectId', request.object.id);
    return query.find().then(function(liens) {
      if (liens.length === 0) {
        return response.success();
      } else {
        return response.error("Lien already created with this objectId");
      }
    }).fail(function(error) {
      return response.error(error);
    });
  } else {
    response.success();
  }
});

Parse.Cloud.beforeSave('LienSub', function(request, response) {
  var query;
  if (request.object.isNew()) {
    query = new Parse.Query('Lien');
    query.equalTo('type', request.object.get('type'));
    query.equalTo('sub_date', request.object.get('sub_date'));
    return query.find().then(function(liens) {
      if (liens.length === 0) {
        return response.success();
      } else {
        return response.error("LienSub already created with this objectId");
      }
    }).fail(function(error) {
      return response.error(error);
    });
  } else {
    response.success();
  }
});

Parse.Cloud.beforeSave('Township', function(request, response) {
  var query;
  if (request.object.isNew()) {
    query = new Parse.Query('Township');
    query.equalTo('township', request.object.get('township'));
    return query.find().then(function(townships) {
      if (townships.length === 0) {
        return response.success();
      } else {
        return response.error("township already created with this objectId");
      }
    }).fail(function(error) {
      return response.error(error);
    });
  } else {
    response.success();
  }
});

},{}]},{},[1]);
