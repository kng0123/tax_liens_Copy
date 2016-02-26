{Action, Templates, SmartTemplates} = require('../script.coffee')
global.SmartTemplates = SmartTemplates
Styleguide = require('../styleguide')

store = require('./store.jsx')
{onEnter, conn, redirect, onLeave} = require('./route_manager.coffee')

global.RouteContext = ReactRouter.hashHistory
Root = React.createClass
  displayName:'Root'

  render: ->
    Router = React.createFactory ReactRouter.Router
    Route = React.createFactory ReactRouter.Route
    IndexRoute = React.createFactory ReactRouter.IndexRoute
    provider = React.createFactory ReactRedux.Provider
    Factory = React.Factory
    {div} = React.DOM
    { DevTools, DebugPanel, LogMonitor } = ReduxDevLibs
    DevTools = React.createFactory DevTools
    DebugPanel = React.createFactory DebugPanel
    LogMonitor = React.createFactory LogMonitor

    #TODO:
    # Only able to nest requirements one deep.
    # Only the top level route is allowed to define requirements
    provider store:store,
      Router history:RouteContext,
        Route path:'/test', component:conn(Styleguide.Molecules.Grids.Example)
        Route path:'/', onEnter:redirect('/lien'), component:conn(Templates.document),
          IndexRoute component:conn(Styleguide.Organisms.Auth.SignIn)
        Route path:'auth', component:conn(Templates.document_box), onEnter:onEnter(conditions:['logged_out'], errorRoute:'/lien'),
          IndexRoute component:conn(Styleguide.Organisms.Auth.SignIn)
          Route path:'sign_in', component:conn(Styleguide.Organisms.Auth.SignIn)
          Route path:'sign_up', component:conn(Templates.sign_up)
        Route path:'lien', component:conn(Templates.document_box), onEnter:onEnter(conditions:['logged_in'], errorRoute:'/auth'),
          IndexRoute component:conn(Templates.lien_list)
          Route path:'upload', component:conn(Templates.lien_upload)
          Route path:'subs', component:conn(Templates.lien_process_subs)
          Route path:'item/:id', component:conn(Templates.lien)

          # Route path:'forgot_password', component:conn(Templates.forgot_password)

module.exports = Root
