'use strict';
global.$ = require('jquery');
var React = require('react');
var ReactDOM = require('react-dom');
global._ = require('underscore')
global.React = React;
global.ReactDOM = ReactDOM;

global.Redux = require("redux")
global.ReactRedux = require("react-redux")
global.ReduxDevtools = require("redux-devtools")
global.ReduxRouter = require("redux-router")
global.ReactHistory = require("history")
global.ReduxDevLibs = require('redux-devtools/lib/react')
global.ReduxRx = require('redux-rx')
global.Select = require('react-select')
global.classNames = require('classnames');
global.Rx = require('rx')
global.RxReact = require('rx-react');
global.RxRecompose = require('meteor-recompose');
global.observeProps = RxRecompose.observeProps;
global.createEventHandler = RxRecompose.createEventHandler;
global.injectTapEventPlugin = require("react-tap-event-plugin")
global.Recompose = require('recompose')
global.moment = require('moment')
global.tv4 = require('tv4')
global.Parse = require('./parse')
global.XLSX = require('xlsx-browserify-shim');

Parse.initialize("4jhLXmNyrqVvhHBfYpAR5wtNtqTLY6o0kt10dICm", "w0DVkEdklERduqzIVTWpUU3hIpn7uUpi58iXux9F");

injectTapEventPlugin = require("react-tap-event-plugin");
global.MUI = require('material-ui');
MUI.Libs = {};
MUI.Libs.Menu = require('material-ui/lib/menus/menu');
MUI.Libs.MenuItem = require('material-ui/lib/menus/menu-item');
MUI.Libs.MenuDivider = require('material-ui/lib/menus/menu-divider');

MUI.Libs.SvgIcons = require('material-ui/lib/svg-icons');

global.ReactRouter = require("react-router");
global.App = {}

global.Test = require('./classes/lien.js')

require('./app.coffee')
