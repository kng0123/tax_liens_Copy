{Action, Templates, SmartTemplates} = require('../script.coffee')
global.SmartTemplates = SmartTemplates
Styleguide = require('../styleguide')

store = require('./store.jsx')
{onEnter, conn} = require('./route_manager.coffee')

Root = React.createClass
  displayName:'Root'

  onLeave: ()->
    router_requirements.pop()

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

    provider store:store,
      Router null,
        Route onLeave:@onLeave, path:'/test', component:conn(Styleguide.Molecules.Forms.Example)
        Route onLeave:@onLeave, path:'/', component:conn(Templates.document),
          IndexRoute component:conn(Templates.lien_list)
        Route onLeave:@onLeave, onEnter:onEnter(conditions:['logged_out'], errorRoute:'/lien'), path:'auth', component:conn(Templates.document_box),
          IndexRoute component:conn(Templates.sign_in)
          Route onLeave:@onLeave, path:'sign_in', component:conn(Templates.sign_in)
          Route onLeave:@onLeave, path:'sign_up', component:conn(Templates.sign_up)
        Route onLeave:@onLeave, onEnter:onEnter(conditions:['logged_in'], errorRoute:'/auth'), path:'lien', component:conn(Templates.document),
          IndexRoute component:conn(Templates.lien_list)
          Route onLeave:@onLeave, path:'upload', component:conn(Templates.lien_upload)
          Route onLeave:@onLeave, path:'subs', component:conn(Templates.lien_process_subs)
          Route onLeave:@onLeave, path:'item/:id', component:conn(Templates.lien)

          # Route path:'forgot_password', component:conn(Templates.forgot_password)

module.exports = Root
