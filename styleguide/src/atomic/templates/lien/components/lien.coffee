accounting = require('accounting')
Templates.lien = React.createClass

  displayName: 'Lien'

  getInitialState: ->
    {div} = React.DOM
    lien: undefined
    open: false
    modal: undefined
    modal_actions: div null, ""

  handleClose: ->
    @setState open: false

  openCreate: ->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.CreateReceipt) Object.assign {lien:@state.lien, callback:=>@setState open:false}, @props, ""
      # modal_actions: [React.createFactory(MUI.FlatButton) label:"Create", secondary:true, onTouchTap: @handleClose]

  getDialog: ->
    modal = @state.modal
    dialog = React.createFactory MUI.Libs.Dialog

    dialog open:@state.open, actions: @state.modal_actions, onRequestClose:@handleClose, contentStyle:{width:'500px'},
      modal

  componentWillMount: ->
    query = new Parse.Query(App.Models.Lien);
    query.equalTo("unique_id", this.props.routeParams.id)
    query.include("subs")
    query.include("checks")
    query.include("owners")
    query.include("llcs")
    query.include("annotations")
    query.find({}).then( (results) =>
      @setState lien: results[0]
    )

  onChange: (item) ->
    (data) =>
      val = switch item.type
        when 'date' then data.toDate()
        when 'bool' then $(data.target).is(':checked')
        when 'select' then data.value
        else  arguments[1]

      lien = @state.lien
      old = lien.get(item.key)
      if typeof(old) == 'number'
        val = parseFloat(val)

      lien.set(item.key, val)
      @setState(lien:lien)
      @save()

  save: ->
    @state.lien.save().then (data) =>
      @setState(lien:data)
    .fail () ->

  render: ->
    {div, h3, h5, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    RaisedButton = React.createFactory MUI.RaisedButton

    lien = @state.lien
    if !lien
      return div null, ""

    state_options = [
        { value: 'redeemed', label: 'Redeemed' },
        { value: 'bankruptcy', label: 'Bankruptcy' },
        { value: 'foreclosure', label: 'Foreclosure' },
        { value: 'own', label: 'Own Home' },
        { value: 'none', label: 'No Subs' },
    ];
    select = React.createFactory Select

    if !@state.lien
      div null, ""
    else
      div null,
        @getDialog()
        div className:'container',
          div className:'row',
            div style:{width:'1200px', margin:'0 auto'},
              Factory.lien_search @props
        div className:'container',
          div className:'row',
            div className:'col-lg-12',
              div className:'container-fluid',
                h5 null,
                  span null, "LIEN #{@state.lien.get('unique_id')}"
                  React.createFactory(MUI.FlatButton) label:"Add receipt", secondary:true, onTouchTap:@openCreate
                  span style:{width:'150px', display:'inline-block'},
                    select name:'status', value:lien.get('status'), options: state_options, onChange:@onChange({type:'select', key:"status"})
                  # React.createFactory(MUI.FlatButton) label:"Add LLC", secondary:true, onTouchTap:@openCreate
          div className:'row',
            div className:'col-md-6',
              Factory.lien_info lien:lien, onChange:@onChange
            div className:'col-md-6',
              Factory.lien_cash lien:lien, onChange:@onChange
          div className:'row',
            div className:'col-md-6',
              Factory.lien_subs lien:lien, onChange:@onChange
            div className:'col-md-6',
              Factory.lien_notes lien:lien, onChange:@onChange
          div className:'row',
            div className:'col-md-12',
              Factory.lien_checks Object.assign {}, @props, lien:lien
          div className:'row',
            div className:'col-md-6',
              Factory.lien_llcs lien:lien, onChange:@onChange
          # div className:'row',
          #   div className:'col-md-12',
          #     Factory.lien_general lien:lien, onChange:@onChange

Templates.lien_general = React.createClass
  displayName: 'LienGeneral'

  render: ->
    #First column from excel GUI
    cash_fields = [

    ]

    general_fields = [
      #TODO there are 2 MUA ACCT's?
      {label: "MUA ACCT 1", key:"mua_account_number", editable:true}
      {label: "MUA ACCT 2", key:"mua_account_number", editable:true}
    ]

    #Second column from excel GUI
    fee_fields = [
    ]
    lien = @props.lien

    editable = React.createFactory PlainEditable
    date_picker = React.createFactory DatePicker
    checkbox = React.createFactory MUI.Checkbox
    gen_editable = (key, item, val) =>
      edit = switch(item.type)
        when 'date'
          div style:{display: 'block', position: 'relative', width: '100px'},
            date_picker className:'form-control datepicker', selected:moment(val), onChange:@props.onChange(item)
        when 'bool' then checkbox onCheck: @props.onChange(item), checked:!!val
        when 'number'
          val = accounting.toFixed(val, 2)
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
                editable onBlur:@props.onChange(item), value:val
          else
            span style:{paddingRight:'15px'}, val
        else
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
              editable onBlur:@props.onChange(item), value:val
          else
            span style:{paddingRight:'10px'}, val
      li key:key, className:'list-group-item compact',

        div style:{float:'left'},
          span null, item.label

        div style:{float:'right'},
          edit
          if ['date', 'bool'].indexOf(item.type) == -1
            span style:{position:'absolute'},
              if item.editable
                i className:"fa fa-pencil"
              else
                i className:"fa fa-times-circle"
        div style:{clear:'both'}, ""

    {div, h3, h1, ul, li, span, i, p} = React.DOM
    div className:'container-fluid',
      div className:'row',
        div className:'col-md-12',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "General"
            div className:'panel-body',
              div style:{width:'50%', float:'left'},
                ul className:'list-group',
                  li className:'list-group-item',
                    React.Factory.lien_llcs lien:lien

              div style:{width:'50%', float:'right' },
                ul className:'list-group',
                  fee_fields.map (v, k) ->
                    val = if lien.get(v.key) is undefined
                      ""
                    else
                      lien.get(v.key)
                    if val instanceof Date
                      val = moment(val).format('MM/DD/YYYY');
                    if typeof val is 'number'
                      val = val.toString()
                    if v.is_function
                      val = lien[v.key]().toString()
                    gen_editable(k, v, val)

Templates.formatter = React.createClass
  displayName: 'formatter'
  click: ->
    alert(1)
  render: ->
    {div} = React.DOM
    fi = React.createFactory MUI.Libs.FontIcons
    iconStyles = {
      color: '#FB8C00'
      marginRight: 10,
    };
    div null,
      fi onClick:@click, className:"muidocs-icon-action-home material-icons orange600", style:iconStyles, "face"
      fi className:"muidocs-icon-action-home material-icons orange600", style:iconStyles, "face"
      fi className:"muidocs-icon-action-home material-icons orange600", style:iconStyles, "face"
      fi className:"muidocs-icon-action-home material-icons orange600", style:iconStyles, "face"

Templates.lien_subs = React.createClass
  displayName: 'LienSubs'

  onSubState: ->

  rowGetter: (i) ->
    sub = @props.lien.get('subs')[i]
    row = {
      type: sub.get('type'),
      date: moment(sub.get('sub_date')).format('MM/DD/YY'),
      amt: sub.amount() || "",
      int: sub.interest(),
      number: "",
      actions: {g:2}
    }
  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    lien = @props.lien

    columns = [
      {name:"TYPE", key:'type'}
      {name:"Sub date", key:'date'}
      {name:"Check #", key:'number'}
      {name:"Date paid", key:'date'}
      {name:"Amount", key:'amt'}
      {name:"Interest", key:'int'}
      {name:"Actions", key:'actions', formatter : Factory.formatter}
    ]

    sub_table = React.createFactory(ReactDataGrid) {
      columns:columns
      enableCellSelect: true
      rowGetter:@rowGetter
      rowsCount:lien.get('subs').length
      minHeight:130
    }

    div className:'panel panel-default',
      div className:'panel-heading',
        h3 className:'panel-title',
          span null, "Subsequents"
        div style:{width:'100%'},
          sub_table

Templates.lien_llcs = React.createClass
  displayName: 'LienLLCs'
  rowGetter: (i) ->
    owner = @props.lien.get('owners')[i]
    row = {
      llc: owner.get('llc'),
      start: moment(owner.get('start_date')).format('MM/DD/YYYY'),
      end: undefined
    }
    if owner.get('end_date')
      row.end = moment(owner.get('end_date')).format('MM/DD/YYYY')
    row
  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    lien = @props.lien


    columns = [
      {name:"LLC", key:'llc'}
      {name:"Start date", key:'start'}
      {name:"End date", key:'end'}
    ]

    llc_table = React.createFactory(ReactDataGrid) {
      columns:columns
      enableCellSelect: true
      rowGetter:@rowGetter
      rowsCount:lien.get('owners').length
      minHeight:130
    }


    div className:'panel panel-default',
      div className:'panel-heading',
        h3 className:'panel-title',
          span null, "Owners"
        div style:{width:'100%'},
          llc_table

Templates.lien_check_actions = React.createClass
  displayName: 'LienCheckActions'
  click: ->
    alert(1)
  render: ->
    {div} = React.DOM
    fi = React.createFactory MUI.Libs.FontIcons
    iconStyles = {
      color: '#FB8C00'
      marginRight: 10,
    };

    div null,
      fi onClick:@props.value.onClick, className:"muidocs-icon-action-home material-icons orange600", style:iconStyles, "edit"

Templates.lien_checks = React.createClass
  displayName: 'LienChecks'

  getInitialState: ->
    {div} = React.DOM
    open: false
    modal: undefined
    modal_actions: div null, ""

  handleClose: ->
    @setState open: false

  openCreate: ->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.CreateReceipt) @props, ""
      modal_actions: [React.createFactory(MUI.FlatButton) label:"Create", secondary:true, onTouchTap: @handleClose]

  openEdit: (receipt)->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.EditReceipt) Object.assign {receipt: receipt, callback:=>@setState open:false}, @props, ""
      # modal_actions: [React.createFactory(MUI.FlatButton) label:"Edit", secondary:true, onTouchTap: @handleClose]

  getDialog: ->
    modal = @state.modal
    dialog = React.createFactory MUI.Libs.Dialog

    dialog open:@state.open, actions: @state.modal_actions, onRequestClose:@handleClose, contentStyle:{width:'400px'},
      modal


  rowGetter: (i) ->
    receipt = @props.lien.get('checks')[i]
    {
      deposit_date: moment(receipt.get('deposit_date')).format('MM/DD/YYYY')
      account: "NA"
      check_date: moment(receipt.get('check_date')).format('MM/DD/YYYY')
      check_number: receipt.get('check_number')
      redeem_date: if receipt.get('redeem_date') then moment(receipt.get('redeem_date')).format('MM/DD/YYYY') else ""
      check_amount: receipt.get('check_amount')
      principal: receipt.get('check_principal')
      subs: receipt.get('check_interest')
      code: receipt.get('type')
      expected_amt: receipt.expected_amount()
      dif: receipt.expected_amount() - receipt.get('check_amount')
      actions: {onClick:@openEdit.bind(@, receipt), receipt:receipt}
    }

  getColumns: () ->
    {div} = React.DOM
    fi = React.createFactory MUI.Libs.FontIcons

    columns = [
      {name:"Deposit date", key:'deposit_date'}
      {name:"Redeem date", key:'redeem_date'}
      {name:"Account", key:'account'}
      {name:"Check date", key:'check_date'}
      {name:"Check #", key:'check_number'}
      {name:"Code", key:'code'}
      {name:"Check amount", key:'check_amount'}
      {name:"Expected Amt", key:'expected_amt'}
      {name:"Dif", key:'dif'}
      {name:"Actions", key:'actions', formatter: React.Factory.lien_check_actions}
    ]

  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien

    receipt_table = React.createFactory(ReactDataGrid) {
      columns:@getColumns()
      enableCellSelect: true
      rowGetter:@rowGetter
      rowsCount:lien.get('checks').length
      minHeight:130
    }

    div className:'panel panel-default',
      div className:'panel-heading',
        # h3 className:'panel-title',
        #   span null, "Receipts"
        #   React.createFactory(MUI.FlatButton) label:"Add receipt", secondary:true, onTouchTap:@openCreate
        @getDialog()
        div style:{width:'100%'},
          receipt_table


Templates.lien_notes = React.createClass
  displayName: 'LienNotes'

  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien
    notes = lien.get('annotations')

    div className:'panel panel-default',
      div className:'panel-heading',
        h3 className:'panel-title', "Notes"
        ul className:'list-group', style:{height:'130px'},
          notes.map (note, key) ->
            div key:key, "BLAH"

Templates.lien_info = React.createClass
  displayName: 'LienInfo'

  render: ->
    {div, h3, h1, ul, li, span, i, p, label, fieldset, input, form,small, br} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien
    notes = lien.get('annotations')

    general_fields = [
      [{label: "Lien ID", key:"unique_id"}
      {label: "BLOCK/LOT/QUAL", key:"block_lot"}
      {label: "TOWNSHIP", key:"county", editable:false}
      {label: "CERTIFICATE #", key:"cert_number", editable:true}
      {label: "MUA ACCOUNT #s", key:"mua_account_number", editable:true}
      ]

      [{label: "ADDRESS", key:"address", editable:true}
      {label: "CITY", key:"city", editable:true}
      {label: "STATE", key:"state", editable:true}
      {label: "ZIP", key:"zip", editable:true}]

      [
        {label: "SALE DATE", key:"sale_date", editable:true, type:'date'}
        {label: "RECORDING DATE", key:"recording_date", editable:true, type:'date'}
        {label: "REDEMPTION DATE", key:"redemption_date", editable:true, type:'date'}
        {label: "REDEEM IN 10?", key:"redeem_in_10", editable:true, type:'bool'}
      ]
    ]

    editable = React.createFactory PlainEditable
    date_picker = React.createFactory DatePicker
    checkbox = React.createFactory MUI.Checkbox
    gen_editable = (key, item, val) =>
      edit = switch(item.type)
        when 'date'
          div style:{display: 'block', position: 'relative', width: '100px'},
            date_picker className:'form-control datepicker', selected:moment(val), onChange:@props.onChange(item)
        when 'bool'
          checkbox onCheck: @props.onChange(item), checked:!!val
        when 'number'
          val = accounting.toFixed(val, 2)
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
                editable onBlur:@props.onChange(item), value:val
          else
            span style:{paddingRight:'15px'}, val
        else
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
              editable onBlur:@props.onChange(item), value:val
          else
            small className:'text-muted', val || "Empty"

      fieldset style:{marginBottom:'0px'}, className:'form-group', key:key,
        div null,
          label style:{marginBottom:'0px'}, item.label
        edit

    div className:'panel panel-default',
      div className:'panel-heading',
        form className:'container-fluid',
          div className:'row',
            general_fields.map( (fields,k) =>
              div className:'col-lg-4', key:k,
                fields.map( (field, field_key) =>
                  val = @props.lien.get(field.key)
                  val = "Empty" if val is undefined and field.type != 'bool'
                  gen_editable(field_key, field, val)
                )
            )

Templates.lien_cash = React.createClass
  displayName: 'LienCash'

  render: ->
    {div, h3, h1, ul, li, span, i, p, label, fieldset, input, form,small, br} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien

    notes = lien.get('annotations')

    #Second column from excel GUI
    fields = [

      [
        {label: "WINNING RATE", key:"winning_bid", editable:true}
        {label: "RECORDING FEE", key:"recording_fee", editable:true, type:'number'}
        {label: "SEARCH FEE", key:"search_fee", is_function:true, editable:true}
        {label: "YEAR END PENALTY", key:"2013_yep", editable:true, type:'number'}
      ]
      [
        {label: "FACE VALUE", key:"cert_fv", editable:false, type:'number'}
        {label: "PREMIUM", key:"premium", editable:false, type:'number'}
        {label: "TOTAL PAID", key:"total_paid", editable:false, type:'number'}
        {label: "FLAT RATE", key:"flat_rate", is_function:true, type:'number'}
        {label: "CERT INT", key:"cert_interest", is_function:true, type:'number'}
      ]
      [


        # {label: "REDEMPTION AMOUNT", key:"redemption_amt", editable:true, type:'number'}
        {label: "TOTAL CASH OUT", key:"total_cash_out", is_function:true, type:'number'}
        {label: "TOTAL INT DUE", key:"total_interest_due", is_function:true, type:'number'}
        #TODO Calculate expected amt
        {label: "EXPECTED AMT", key:"expected_amount", is_function:true, type:'number'}
        #TODO: No longer required
        {label: "MZ CHECK", key:"total_check", is_function:true}
        {label: "DIFFERENCE", key:"diff", is_function:true, type:'number'}
      ]
    ]

    editable = React.createFactory PlainEditable
    date_picker = React.createFactory DatePicker
    checkbox = React.createFactory MUI.Checkbox
    gen_editable = (key, item, val) =>
      edit = switch(item.type)
        when 'date'
          div style:{display: 'block', position: 'relative', width: '100px'},
            date_picker className:'form-control datepicker', selected:moment(val), onChange:@props.onChange(item)
        when 'bool' then checkbox onCheck: @props.onChange(item), checked:!!val
        when 'number'
          val = accounting.toFixed(val, 2)
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
                editable onBlur:@props.onChange(item), value:val
          else
            span style:{paddingRight:'15px'}, val
        else
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
              editable onBlur:@props.onChange(item), value:val
          else
            small className:'text-muted', val || "Empty"

      fieldset style:{marginBottom:'0px'}, className:'form-group', key:key,
        div null,
          label style:{marginBottom:'0px'}, item.label
        edit

    div className:'panel panel-default',
      div className:'panel-heading',
        form className:'container-fluid',
          div className:'row',
            fields.map( (fields,k) =>
              div className:'col-lg-4', key:k,
                fields.map( (field, field_key) =>
                  val = if @props.lien.get(field.key) is undefined
                    ""
                  else
                    @props.lien.get(field.key)
                  if val instanceof Date
                    val = moment(val).format('MM/DD/YYYY');
                  if typeof val is 'number'
                    val = val.toString()
                  if field.is_function
                    val = @props.lien[field.key]().toString()
                  val = "Empty" if val is undefined
                  gen_editable(field.key, field, val)
                )
            )
