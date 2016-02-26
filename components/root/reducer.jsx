var reducer;

reducer = Redux.combineReducers({
  router: ReduxRouter.routerStateReducer,
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
      case 'INIT_SEARCH':
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
  }
});

export default reducer
