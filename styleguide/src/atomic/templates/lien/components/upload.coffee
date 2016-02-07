Templates.lien_upload = React.createClass
  displayName: 'LienUpload'

  getInitialState: ->
    data: []

  handleFile: (e) ->
    files = e.target.files
    i = undefined
    f = undefined
    i = 0
    f = files[i]
    while i != files.length
      reader = new FileReader
      name = f.name

      reader.onload = (e) =>
        data = e.target.result

        lien_xlsx = new App.Utils.LienXLSX(data)
        @setState(data: data.concat(lien_xlsx.liens))

        # promises = objects.map (lien) =>
        #   Lien.init_from_json(lien)
        # @setState(data:[])
        # Parse.Promise.when(promises).then () =>
        #   data = @state.data
        #   @setState(data: data.concat(Array.prototype.slice.call(arguments)))
        # .fail (liens) =>
        #   data = @state.data
        #   @setState(data: data.concat(liens))

      reader.readAsBinaryString f

      ++i
    return

  handleClick: ->
     fileUploadDom = React.findDOMNode(@refs.fileUpload);
     fileUploadDom.click();

  render: ->
    {div, h3, h1, input, pre} = React.DOM
    Factory = React.Factory

    RaisedButton = React.createFactory MUI.RaisedButton
    data = @state.data || []

    Table = React.createFactory MUI.Table
    TableHeader = React.createFactory MUI.TableHeader
    TableRow = React.createFactory MUI.TableRow
    TableHeaderColumn = React.createFactory MUI.TableHeaderColumn
    TableBody = React.createFactory MUI.TableBody
    TableRowColumn = React.createFactory MUI.TableRowColumn
    RaisedButton = React.createFactory MUI.RaisedButton

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
      onRowSelection: (->)


    table = Table table_props,
      TableHeader enableSelectAll:table_state.enableSelectAll,
        TableRow null,
          TableHeaderColumn null, "ID"
          TableHeaderColumn null, "Status"
      TableBody deselectOnClickaway:table_state.deselectOnClickaway, showRowHover:table_state.showRowHover, stripedRows:table_state.stripedRows,
        data.map (v, k) ->
          status = "SUCCESS"
          if v.error
            status = "ERROR"
          TableRow key:v.get('unique_id'),
            TableRowColumn null, v.get('unique_id')
            TableRowColumn null, status

    div className:'container',
      div className:'row',
        div className:'col-lg-12',
          h1 null, "Upload an xlsx file"
      div className:'row',
        div className:'col-lg-12',
          RaisedButton label:"Upload", type:'button', primary:true, onClick:@handleClick
          input ref:"fileUpload", style:{display:'none'}, type:'file', onChange:@handleFile

      if data
        div className:'row',
          div className:'col-lg-12',
            table
