'use strict';

global.$ = require('jquery');
var React = require('react');
var ReactDOM = require('react-dom');
require('babel-polyfill')
// global._ = require('underscore')
global.React = React;
global.ReactDOM = ReactDOM;
let {FactoryPanda, FactoryDefinition} = require('factory-panda');
global.FactoryPanda = FactoryPanda
global.FactoryDefinition=FactoryDefinition

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
global.Select = require('react-select')
global.RxReact = require('rx-react');
global.RxRecompose = require('meteor-recompose');
global.observeProps = RxRecompose.observeProps;
global.createEventHandler = RxRecompose.createEventHandler;
global.injectTapEventPlugin = require("react-tap-event-plugin")
global.Recompose = require('recompose')
global.moment = require('moment')
global.tv4 = require('tv4')
global.Parse = require('./parse.js')
global.ParseReact = require('parse-react')
global.moment = require('moment')
global.XLSX = require('xlsx-browserify-shim');
global.PlainEditable = require('react-plain-editable');
global.DatePicker = require('react-datepicker');

// if (process.env.BROWSER) {
//TODO: HOw do we parse this only for the browser builds?
require('./app.css')
// }


// Parse.initialize("4jhLXmNyrqVvhHBfYpAR5wtNtqTLY6o0kt10dICm", "w0DVkEdklERduqzIVTWpUU3hIpn7uUpi58iXux9F");
Parse.initialize("fake_app", "javascriptKey");
Parse.serverURL = ('/parse');
require('react.backbone')

injectTapEventPlugin = require("react-tap-event-plugin");
global.MUI = require('material-ui');
MUI.Libs = {
  Menu: require('material-ui/lib/menus/menu'),
  MenuItem: require('material-ui/lib/menus/menu-item'),
  MenuDivider: require('material-ui/lib/menus/menu-divider'),
  SvgIcons: require('material-ui/lib/svg-icons'),
  FontIcons: require('material-ui/lib/font-icon'),
  Dialog: require('material-ui/lib/dialog')
};

global.ReactRouter = require("react-router");
//TODO: If we require inside an object we're not picking up changes

global.App = {
  Models: require('./classes'),
  Utils: require('./utils'),
}
require('./backbone')
import ReactDataGrid from 'react-data-grid'
global.ReactDataGrid = ReactDataGrid
global.Styleguide = require('./styleguide')
require('./root')(App)
