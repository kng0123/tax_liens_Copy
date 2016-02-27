import {default as reducer} from './reducer.jsx'

var thunk = function(store) {
  return function(next) {
    return function(action) {
      if (typeof action === 'function') {
        return action(store.dispatch, store.getState);
      } else {
        return next(action);
      }
    };
  };
};

import { Router, Route, browserHistory } from 'react-router'
import { syncHistory, routeReducer } from 'redux-simple-router'
const reduxRouterMiddleware = syncHistory(ReactRouter.hashHistory)

var store = Redux.compose(
  Redux.applyMiddleware(thunk, reduxRouterMiddleware),
  ReduxDevtools.devTools()
)(Redux.createStore)(reducer)

reduxRouterMiddleware.listenForReplays(store)
export default store
