store = require('./store.jsx')
{ routeActions } = require 'redux-simple-router'

global.router_requirements = []
conditions =
  logged_in: -> !!store.getState().user.id
  logged_out: -> !store.getState().user.id

checkRequirements = (r) ->
  (r || router_requirements).reduce( (meets_requirements, requirement) =>
    meets_requirements && requirement.conditions.reduce( (meets_conditions, condition) ->
      meets_conditions && conditions[condition]()
    , true)
  , true)

exports.onEnter = (route_props) ->
  (nextState, replace) =>
    console.log "ENTERING"
    console.log route_props.errorRoute
    console.log global.router_requirements
    if !checkRequirements([route_props])
      replace route_props.errorRoute
    else
      global.router_requirements = [route_props]

exports.redirect = (route) ->
  (nextState, replace) =>
    replace(route)

exports.conn = conn = ReactRedux.connect((state) ->
  state
)
app_stream = ReduxRx.observableFromStore(store)
app_stream.subscribe () ->
  if !checkRequirements()
    last = router_requirements[global.router_requirements.length-1]
    global.router_requirements = []
    ReactRouter.hashHistory.push(last.errorRoute)
