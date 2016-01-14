{Action, Templates, SmartTemplates} = require('./script.coffee')
global.SmartTemplates = SmartTemplates
reducer = Redux.combineReducers(
  router: ReduxRouter.routerStateReducer
  user: (state, action) ->
    user = Parse.User.current() || {}
    if !state
      return Object.assign({}, user || {})
    switch action.type
      when 'USER_CHANGE' then Object.assign({}, user)
      when 'USER_UNSET' then {}
      else state
  auth_link: (state, action) ->
    if !state
      return {}
    switch action.type
      when 'AUTH_LINK' then action
      when 'AUTH_LINK_COMPLETE' then {}
      else state
)

thunk = (store) => (next) => (action) =>
  if typeof action == 'function'
    action(store.dispatch, store.getState)
  else
    next(action)

App.store = store = Redux.compose(
  Redux.applyMiddleware(thunk),
  ReduxRouter.reduxReactRouter(ReactHistory),
  ReduxDevtools.devTools()
)(Redux.createStore)(reducer)

app_stream = ReduxRx.observableFromStore(App.store)

app_stream.subscribe (store) ->
  return if !store.router
  logged_in = store.user.id
  is_auth = store.router.location.pathname.indexOf('auth') != -1

  if !logged_in and !is_auth
    App.store.dispatch(ReduxRouter.pushState(null, '/auth/sign_in'))
  else if !logged_in
    return
  else if logged_in and is_auth
    App.store.dispatch(ReduxRouter.pushState(null, '/'))

Root = React.createClass
  displayName:'Root'

  render: ->
    Router = React.createFactory ReduxRouter.ReduxRouter
    Route = React.createFactory ReactRouter.Route
    IndexRoute = React.createFactory ReactRouter.IndexRoute
    provider = React.createFactory ReactRedux.Provider
    Factory = React.Factory
    {div} = React.DOM
    { DevTools, DebugPanel, LogMonitor } = ReduxDevLibs
    DevTools = React.createFactory DevTools
    DebugPanel = React.createFactory DebugPanel
    LogMonitor = React.createFactory LogMonitor

    conn = ReactRedux.connect((s)->s)

    provider store:store,
      Router null,
        Route path:'/', component:conn(Templates.document),
          IndexRoute component:conn(Templates.lien_list)
        Route path:'auth', component:conn(Templates.document_box),
          IndexRoute component:conn(Templates.authorization)
          Route path:'sign_in', component:conn(Templates.sign_in)
          Route path:'sign_up', component:conn(Templates.sign_up)
        Route path:'lien', component:conn(Templates.document),
          IndexRoute component:conn(Templates.lien_list)
          Route path:'upload', component:conn(Templates.lien_upload)
          Route path:'item/:id', component:conn(Templates.lien)
          # Route path:'forgot_password', component:conn(Templates.forgot_password)

$(document).ready(->
  injectTapEventPlugin()
  element = React.createElement(Root)
  ReactDOM.render(element, $("#content")[0]);
)
