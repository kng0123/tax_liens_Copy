
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
