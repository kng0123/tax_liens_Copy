store = require('./store.jsx')
router_requirements = []
conditions =
  logged_in: -> !!store.getState().user.id
  logged_out: -> !store.getState().user.id

checkRequirements = () ->
  router_requirements.reduce( (meets_requirements, requirement) =>
    meets_requirements && requirement.conditions.reduce( (meets_conditions, condition) ->
      meets_conditions && conditions[condition]()
    , true)
  , true)

exports.onEnter = (route_props) ->
  (nextState, replaceState) =>
    router_requirements.push(route_props)
    if !checkRequirements()
      router_requirements.pop()
      replaceState null, route_props.errorRoute

exports.onLeave = ()->
  router_requirements.pop()

exports.redirect = (route) ->
  (nextState, replaceState) =>
    replaceState null, route

exports.conn = conn = ReactRedux.connect((state) ->
  if checkRequirements()
    state
  else
    last = router_requirements[router_requirements  .length-1]
    store.dispatch(ReduxRouter.pushState(null, last.errorRoute))
)
