Templates.lien_list = React.createClass
  displayName: 'LienList'
  contextTypes: {
    router: React.PropTypes.object
  },
  getInitialState: ->
    liens: []
    open: false
    modal: undefined

  handleClose: ->
    @setState open: false

  exportReceipts: ->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.ExportReceipts) Object.assign {liens:@state.liens, callback:=>@setState open:false}, @props, ""
  exportLiens: ->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.ExportLiens) Object.assign {liens:@state.liens, callback:=>@setState open:false}, @props, ""

  getDialog: ->
    modal = @state.modal
    dialog = React.createFactory MUI.Libs.Dialog
    dialog open:@state.open, actions: @state.modal_actions, onRequestClose:@handleClose, contentStyle:{width:'500px'},
      modal

  componentWillMount: ->
    @queryLiens(@props)

  componentWillReceiveProps: (props)->
    @queryLiens(props)

  queryLiens: (props)->
    query_params = props.search
    query = new Parse.Query(App.Models.Lien);
    if !query_params
      return
    if query_params.id
      query.equalTo("objectId", query_params.id)
    else if query_params.block
      query.equalTo("block", query_params.block)
      query.equalTo("lot", query_params.lot) if query_params.lot
      query.equalTo("qualifier", query_params.qualifier) if query_params.qualifier
    else if query_params.cert
      query.equalTo("cert_number", query_params.cert)
    else if query_params.sale_year
      year = parseInt(query_params.sale_year)
      query.greaterThan("sale_date", moment([year, 0]).toDate());
      query.lessThan("sale_date", moment([year+1, 0]).toDate());
    else if query_params.township
      query.contains("county", query_params.township)
    else
      return

    #TODO What to do with case #?
    query.include("subs")
    query.include("checks")
    query.include("owners")
    query.include("llcs")
    query.include("annotations")
    query.find({
    	success : (results) =>
        @setState liens:results
    	,
    	error : (obj, error) ->

    })

  goToLien: (indices) ->
    lien = @state.liens[indices[0]]
    @context.router.push('/lien/item/'+lien.id)


  render: ->
    {div, h3, h1, p} = React.DOM
    Factory = React.Factory

    table_state = {
      fixedHeader: true,
      fixedFooter: true,
      stripedRows: false,
      showRowHover: false,
      selectable: true,
      multiSelectable: false,
      enableSelectAll: false,
      deselectOnClickaway: true,
      height: '300px',
    };

    table_props =
      height: table_state.height
      fixedHeader: table_state.fixedHeader
      fixedFooter: table_state.fixedFooter
      selectable: table_state.selectable
      multiSelectable: table_state.multiSelectable
      onRowSelection: @goToLien

    Table = React.createFactory MUI.Table
    TableHeader = React.createFactory MUI.TableHeader
    TableRow = React.createFactory MUI.TableRow
    TableHeaderColumn = React.createFactory MUI.TableHeaderColumn
    TableBody = React.createFactory MUI.TableBody
    TableRowColumn = React.createFactory MUI.TableRowColumn
    RaisedButton = React.createFactory MUI.RaisedButton

    table = Table table_props,
      TableHeader enableSelectAll:table_state.enableSelectAll,
        TableRow null,
          TableHeaderColumn null, "ID"
          TableHeaderColumn null, "Name"
          TableHeaderColumn null, "Status"
      TableBody deselectOnClickaway:table_state.deselectOnClickaway, showRowHover:table_state.showRowHover, stripedRows:table_state.stripedRows,
        @state.liens.map (v, k) ->
          TableRow key:k,
            TableRowColumn null, v.id
            TableRowColumn null, 'Data'
            TableRowColumn null, 'Data'

    div null,
      @getDialog()
      div className:'container-fluid',
        div className:'row',
          div style:{width:'1200px', margin:'0 auto'},
            Factory.lien_search @props
      div className:'container',
        div className:'row',
          if @state.liens.length
            div className:'col-lg-12',
              React.createFactory(MUI.FlatButton) label:"Export receipts", secondary:true, onTouchTap:@exportReceipts
              React.createFactory(MUI.FlatButton) label:"Export liens", secondary:true, onTouchTap:@exportLiens
        div className:'row',
          div className:'col-lg-12',
            if @state.liens.length
              table
            else
              p null, "No liens found. Try uploading some."
