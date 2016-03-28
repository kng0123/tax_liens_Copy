Templates = @Templates = {}
DumbTemplates = @DumbTemplates = {}
SmartTemplates = @SmartTemplates = {}

Action = {
  attempt_sign_in: ({username, password}) ->
    subject = new Rx.AsyncSubject()
    action =  (dispatch, getState) ->
      Parse.User.logIn(username, password, {
        success: (user) ->
          dispatch type: 'USER_CHANGE'
          subject.onNext(error: null, response: user)
          subject.onCompleted()
          subject.dispose()
        error: (user, error) ->
          subject.onNext(error: error, response: user)
          subject.onCompleted()
          subject.dispose()
      })
    action.subject = subject
    return action
  attempt_sign_up: ({username, password}) ->
    subject = new Rx.AsyncSubject()
    action =  (dispatch, getState) ->
      Parse.User.signUp(username, password, {ACL: new Parse.ACL()}, {
        success: (user) ->
          dispatch type: 'USER_CHANGE'
          subject.onNext(error: null, response: user)
          subject.onCompleted()
          subject.dispose()
        error: (user, error) ->
          subject.onNext(error: error, response: user)
          subject.onCompleted()
          subject.dispose()
      })
    action.subject = subject
    return action

  logout: ->
    (dispatch, getState) ->
      Parse.User.logOut()
      dispatch type: 'USER_CHANGE'
}

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
      selectable: @props.selectable,
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
      onRowSelection: @props.onRowSelection

    # debugger

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


Templates.lien_list = React.createBackboneClass
  displayName: 'Lien'
  getInitialState: ->
    liens: new BackboneApp.Collections.LienCollection()

  render: ->
    return React.Factory.lien_list_helper(Object.assign({}, @props, liens:@state.liens))

Templates.lien_list_helper = React.createClass
  displayName: 'LienListHelper'
  mixins: [
      React.BackboneMixin("liens")
  ],
  contextTypes: {
    router: React.PropTypes.object
  },
  getInitialState: ->
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
    props.liens.fetch(query_params)

  goToLien: (indices) ->
    @context.router.push('/lien/item/'+indices.target.dataset.id)


  render: ->
    {div, h3, h1, p} = React.DOM
    Factory = React.Factory
    RaisedButton = React.createFactory MUI.RaisedButton

    sub_headers = ["ID", "TOWNSHIP", "BLOCK", "LOT", "QUALIFIER", "MUA ACCT 1", "CERTIFICATE #", "ADDRESS", "SALE DATE"]
    editable = React.createFactory PlainEditable
    sub_rows = @props.liens.models.map (lien, k) =>
      [
        lien.get('id'),
        div onClick:@goToLien, 'data-id':lien.get('id'), lien.get('county')
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).format('MM/DD/YYYY')
      ]

    widths = ['40px', '20px','20px','30px','50px','50px','50px','50px','50px','50px']

    sub_table = Factory.table widths:widths, selectable:true, headers: sub_headers, rows: sub_rows#, onRowSelection:@goToLien

    div null,
      @getDialog()
      div className:'container-fluid',
        div className:'row',
          div style:{width:'1200px', margin:'0 auto'},
            Factory.lien_search @props
      div className:'container-fluid',
        div className:'row',
          if @props.liens.length
            div className:'col-lg-12',
              React.createFactory(MUI.FlatButton) label:"Export receipts", secondary:true, onTouchTap:@exportReceipts
              React.createFactory(MUI.FlatButton) label:"Export liens", secondary:true, onTouchTap:@exportLiens
        div className:'row',
          div className:'col-lg-12',
            if @props.liens.length
              sub_table
            else
              p null, "No liens found. Try uploading some."


Templates.lien_upload = React.createClass
  displayName: 'LienUpload'

  getInitialState: ->
    lien_xlsx: undefined
    uploading: false
    status: ""
    error: ""

  handleFile: (e) ->
    files = e.target.files
    i = 0
    f = files[i]
    while i != files.length
      reader = new FileReader
      name = f.name
      reader.onload = (e) =>
        data = e.target.result
        lien_xlsx = new App.Utils.LienXLSX(data)
        @setState({
          lien_xlsx: lien_xlsx
          uploading:false
        })
        # lien_xlsx.create()
      reader.readAsBinaryString f
      ++i

  handleCreate: ->
    @setState({
      uploading: true
      status: "Creating objects..."
    })
    @state.lien_xlsx.create().then(() =>
      @setState({
        status: "Upload complete"
      })
    ).fail((error) =>
      @setState({
        status: "Upload failed"
        error: error
      })
    )

  handleClick: ->
     fileUploadDom = React.findDOMNode(@refs.fileUpload);
     fileUploadDom.click();

  render: ->
    {div, h3, h1, input, pre, span} = React.DOM
    Factory = React.Factory
    RaisedButton = React.createFactory MUI.RaisedButton

    div className:'container',
      div className:'row',
        div className:'col-lg-12',
          h1 null, "Upload an xlsx file"
      div className:'row',
        div className:'col-lg-12',
          RaisedButton label:"Upload", type:'button', primary:true, onClick:@handleClick
          input ref:"fileUpload", style:{display:'none'}, type:'file', onChange:@handleFile
      if @state.lien_xlsx
        data= @state.lien_xlsx
        div className:'row',
          div className:'col-lg-12',
            div className:'panel panel-default',
              div className:'panel-heading',
                h3 className:'panel-title',
                  span null, "Data that will be uploaded"
              div className:'panel-body',
                div style:{width:'100%'},
                  div null,
                   span null, "Townships: "
                   span null, data.townships.length
                  div null,
                   span null, "Liens: "
                   span null, data.objects.length
                  if !@state.uploading
                    div key:1,
                      RaisedButton label:"Create liens", type:'button', primary:false, onClick:@handleCreate
                  else
                    div key:1,
                      span null, @state.status
                      span null, JSON.stringify(@state.error)

React.Factory = {}
for x, y of Templates
  React.Factory[x] = React.createFactory y
