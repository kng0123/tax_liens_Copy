'use strict';

global.$ = require('jquery');
var React = require('react');
var ReactDOM = require('react-dom');
require('babel-polyfill')
// global._ = require('underscore')
global.React = React;
global.ReactDOM = ReactDOM;
// let {FactoryPanda, FactoryDefinition} = require('factory-panda');
// global.FactoryPanda = FactoryPanda
// global.FactoryDefinition=FactoryDefinition

global.Redux = require("redux")
global.ReactRedux = require("react-redux")
// global.ReduxDevtools = require("redux-devtools")
global.ReduxRouter = require("redux-router")
global.ReactHistory = require("history")
global.ReduxRx = require('redux-rx')
global.Select = require('react-select')
global.classNames = require('classnames');

global.injectTapEventPlugin = require("react-tap-event-plugin")
global.Recompose = require('recompose')
global.moment = require('moment')
global.PlainEditable = require('react-plain-editable');
global.DatePicker = require('react-datepicker');

// if (process.env.BROWSER) {
//TODO: HOw do we parse this only for the browser builds?
require('./app.css')
// }

require('react.backbone')

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
}
require('./backbone')
import ReactDataGrid from 'react-data-grid'
global.ReactDataGrid = ReactDataGrid
global.Styleguide = require('./styleguide')
require('./root')(App)
