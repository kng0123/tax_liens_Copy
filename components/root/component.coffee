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
        Route path:'/', onEnter:redirect('/lien'), component:conn(Styleguide.Organisms.Document.DocumentBox),
          IndexRoute component:conn(Styleguide.Organisms.Auth.SignIn)
        Route path:'lien', component:conn(Styleguide.Organisms.Document.DocumentBox), onEnter:onEnter(conditions:['logged_in'], errorRoute:'/auth'),
          IndexRoute component:conn(Styleguide.Pages.LienList)
          Route path:'upload', component:conn(Templates.lien_upload)
          Route path:'subs', component:conn(Templates.lien_process_subs)
          Route path:'batch/:id', component:conn(Templates.lien_process_subs_list)
          Route path:'item/:id', component:conn(Styleguide.Pages.Lien)

module.exports = Root
