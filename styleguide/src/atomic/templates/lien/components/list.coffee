Templates.lien_list = React.createClass
  displayName: 'LienList'

  getInitialState: ->
    liens: []

  componentWillMount: ->
    Lien = Parse.Object.extend("Lien");
    query = new Parse.Query(Lien);
    query.find({
    	success : (results) =>
        data = results.map (item) ->
          item._toFullJSON()
        @setState liens:data
    	,
    	error : (obj, error) ->
    })

  goToLien: (indices) ->
    lien = @state.liens[indices[0]]
    @props.dispatch(ReduxRouter.pushState(null, '/lien/item/'+lien.objectId))

  goToUpload: () ->
    @props.dispatch(ReduxRouter.pushState(null, '/lien/upload'))

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
          TableRow key:v.objectId,
            TableRowColumn null, v.unique_id
            TableRowColumn null, 'Data'
            TableRowColumn null, 'Data'

    div className:'container',
      div className:'row',
        div className:'col-lg-12',
          RaisedButton label:"Upload", onClick:@goToUpload, type:'button', primary:true

      div className:'row',
        div className:'col-lg-12',
          if @state.liens.length
            table
          else
            p null, "No liens found. Try uploading some."
