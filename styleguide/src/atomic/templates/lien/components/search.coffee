Templates.lien_search = React.createClass
  displayName: 'LienSearch'

  contextTypes: {
    router: React.PropTypes.object
  },

  getInitialState: ->
    data: Object.assign {}, @props.search

  componentWillMount: ->
    @props.dispatch({type:'INIT_SEARCH', data:@props.location.query})

  componentWillReceiveProps: (props)->
    @setState(data: props.search)

  onChange: (event) ->
    name = event.target.name
    val = event.target.value

    data = @state.data
    data[name] = val
    @setState data: data

  onSubmit: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @context.router.push(
      pathname: '/lien',
      query: @state.data
    )
    return false

  render: ->
    {form, div, label, input, button, span} = React.DOM
    inputs = [
        label: "Block", type:'text', key:'block'
      ,
        label: "Lot", type:'text', key:'lot'
      ,
        label: "Qual", type:'text', key:'qualifier'
      ,
        label: "Certificate #", type:'text', key:'cert'
      ,
        label: "Sale year", type:'text', key:'sale_year'
      ,
        label: "Township", type:'text', key:'township'
      ,
        label: "Case #", type:'text', key:'case'
      ,
        label: "Lien ID", type:'text', key:'id'
    ]

    form className:'form-inline', onSubmit:@onSubmit,
      inputs.map (item, index) =>
        div key:index, className:'form-group',
          div style:{display:'block'},
            div null,
              span null, item.label
            input onChange:@onChange, style:{width:'150px'}, type:item.type, name:item.key, value:@state.data[item.key], className:'form-control'
      button type:'submit', className:'btn btn-primary', "Go"
