Templates.table = React.createClass
  displayName: 'Table'

  render: ->

    Table = React.createFactory MUI.Table
    TableHeader = React.createFactory MUI.TableHeader
    TableRow = React.createFactory MUI.TableRow
    TableHeaderColumn = React.createFactory MUI.TableHeaderColumn
    TableBody = React.createFactory MUI.TableBody
    TableRowColumn = React.createFactory MUI.TableRowColumn
    RaisedButton = React.createFactory MUI.RaisedButton

    table_state = {
      fixedHeader: false,
      fixedFooter: false,
      stripedRows: false,
      showRowHover: false,
      selectable: false,
      multiSelectable: false,
      enableSelectAll: false,
      adjustForCheckbox: false,
      deselectOnClickaway: false,
      displayRowCheckbox: false,
      height: @props.height || '600px',
    };

    table_props =
      height: table_state.height
      fixedHeader: table_state.fixedHeader
      fixedFooter: table_state.fixedFooter
      selectable: table_state.selectable
      multiSelectable: table_state.multiSelectable
      onRowSelection: ->

    headers = @props.headers
    rows = @props.rows

    table = Table table_props,
      TableHeader adjustForCheckbox:table_state.adjustForCheckbox, enableSelectAll:table_state.enableSelectAll, displayRowCheckbox:table_state.displayRowCheckbox, displaySelectAll:false,
        TableRow null,
          headers.map (header, index) =>
            props = key:index
            if @props.widths
              props.style = {width:@props.widths[index], textAlign:'center', paddingLeft:0, paddingRight:0}
            TableHeaderColumn props, header

      TableBody deselectOnClickaway:table_state.deselectOnClickaway, showRowHover:table_state.showRowHover, stripedRows:table_state.stripedRows, displayRowCheckbox:table_state.displayRowCheckbox,
        rows.map (row, k) =>
          style = {padding:0, textAlign:'center'}
          TableRow key:k,
            row.map (item, index) =>
              props = key:index
              if @props.widths
                props.style = {width:@props.widths[index], textAlign:'center', paddingLeft:0, paddingRight:0}
              TableRowColumn  props, item
