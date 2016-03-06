Templates.lien_search = React.createClass
  displayName: 'LienSearch'

  contextTypes: {
    router: React.PropTypes.object
  },

  getInitialState: ->
    townships: []
    data: Object.assign {}, @props.search

  componentWillMount: () ->
    query = new Parse.Query('Township');
    return query.find().then( (townships) =>
      @setState townships:townships.map( (township) ->
        label: township.get('township'), value:township.get('township')
      )
    )

  componentWillReceiveProps: (props)->
    @setState data: props.search

  onChange: (event) ->
    if event.label
      data = @state.data
      data['township'] = event.value
      @setState data: data
    else
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
    this.props.dispatch({type:'SEARCH', data:@state.data})
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

    select = React.createFactory Select

    form className:'form-inline', onSubmit:@onSubmit,
      inputs.map (item, index) =>
        div key:index, className:'form-group',
          div style:{display:'block'},
            div null,
              span null, item.label
            if item.key != 'township'
              input onChange:@onChange, style:{width:'130px'}, type:item.type, name:item.key, value:@state.data[item.key], className:'form-control'
            else
              select name:'status', style:{width:'130px'},value:@state.data[item.key], name:item.key, options:@state.townships, onChange:@onChange
      button type:'submit', style:{marginTop:'20px', marginLeft:'10px'}, className:'btn btn-primary', "Go"
