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


var store = Redux.compose(
  Redux.applyMiddleware(thunk),
  ReduxRouter.reduxReactRouter({createHistory: ReactHistory.createHashHistory}),
  ReduxDevtools.devTools()
)(Redux.createStore)(reducer)


export default store
