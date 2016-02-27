var reducer;
import { syncHistory, routeReducer } from 'redux-simple-router'

reducer = Redux.combineReducers({
  routing: routeReducer,
  user: function(state, action) {
    var user;
    user = Parse.User.current() || {};
    if (!state) {
      return Object.assign({}, user || {});
    }
    switch (action.type) {
      case 'USER_CHANGE':
        return Object.assign({}, user);
      case 'USER_UNSET':
        return {};
      default:
        return state;
    }
  },
  search: function(state, action) {
    if (!state) {
      return {
        block: '',
        lot: '',
        qualifier: '',
        cert: '',
        sale_year: '',
        township: '',
        "case": '',
        id: ''
      };
    }
    switch (action.type) {
      case 'SEARCH':
        return Object.assign({}, state, action.data);
      default:
        return state;
    }
  },
  auth_link: function(state, action) {
    if (!state) {
      return {};
    }
    switch (action.type) {
      case 'AUTH_LINK':
        return action;
      case 'AUTH_LINK_COMPLETE':
        return {};
      default:
        return state;
    }
  },
  form: function(state, action) {
    console.log(action);
    if (!state || action.type == "@@reduxReactRouter/routerDidChange") {
      return {};
    }
    switch (action.type) {
      case 'FORM_SUBMIT':
        var new_state = Object.assign({}, state)
        new_state[action.name] = {}
        return new_state
      case 'FORM_RESPONSE':
        var new_state = Object.assign({}, state)
        new_state[action.name] = action
        return new_state
    }
    return state
  }
});

export default reducer
