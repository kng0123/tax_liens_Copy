accounting = require('accounting')
Templates.lien = React.createClass
  displayName: 'Lien'

  getInitialState: ->
    lien: undefined

  componentWillMount: ->
    query = new Parse.Query(App.Models.Lien);
    query.equalTo("unique_id", this.props.routeParams.id)
    query.include("subs")
    query.include("checks")
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
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    RaisedButton = React.createFactory MUI.RaisedButton

    lien = @state.lien
    if !lien
      return div null, ""

    div className:'container-fluid',
      div className:'row',
        div className:'col-lg-12',
          Factory.lien_search @props
      div className:'row',
        div className:'col-lg-12',
          div className:'container-fluid',
            h1 null, "LIEN #{@state.lien.get('unique_id')}"

      if @state.lien
        div className:'row',
          div className:'col-md-6',
            Factory.lien_general lien:lien, onChange:@onChange
          div className:'col-md-6',
            Factory.lien_notes lien:lien
            Factory.lien_subs lien:lien, onChange:@onChange
          div className:'col-md-12',
            Factory.lien_checks lien:lien
      else
        div null, ""

Templates.lien_general = React.createClass
  displayName: 'LienGeneral'

  render: ->
    #First column from excel GUI
    general_fields = [
      {label: "Lien ID", key:"unique_id"}
      {label: "BLOCK/LOT/QUAL", key:"block_lot"}
      {label: "CERTIFICATE #", key:"cert_number", editable:true}

      #TODO LLCs HOW???

      #TODO there are 2 MUA ACCT's?
      {label: "MUA ACCT 1", key:"mua_account_number", editable:true}
      {label: "MUA ACCT 2", key:"mua_account_number", editable:true}
      {label: "SALE DATE", key:"sale_date", editable:true, type:'date'}
      {label: "FACE VALUE", key:"cert_fv", editable:false, type:'number'}
      {label: "PREMIUM", key:"premium", editable:false, type:'number'}
      {label: "TOTAL PAID", key:"total_paid", editable:false, type:'number'}
      {label: "WINNING RATE", key:"winning_bid", editable:true}
      {label: "TOWNSHIP", key:"county", editable:false}
      {label: "ADDRESS", key:"address", editable:true}

      #TODO These are not in the excel
      {label: "CITY", key:"city", editable:true}
      {label: "STATE", key:"state", editable:true}
      {label: "ZIP", key:"zip", editable:true}
    ]

    #Second column from excel GUI
    fee_fields = [
      {label: "RECORDING DATE", key:"recording_date", editable:true, type:'date'}
      {label: "RECORDING FEE", key:"recording_fee", editable:true, type:'number'}
      {label: "SEARCH FEE", key:"search_fee", is_function:true, editable:true}
      {label: "FLAT RATE", key:"flat_rate", is_function:true, type:'number'}
      {label: "CERT INT", key:"cert_interest", is_function:true, type:'number'}
      {label: "YEAR END PENALTY", key:"2013_yep", editable:true, type:'number'}
      {label: "REDEMPTION DATE", key:"redemption_date", editable:true, type:'date'}
      {label: "REDEMPTION AMOUNT", key:"redemption_amt", editable:true, type:'number'}
      #TODO What is redeem within 10 days
      {label: "REDEEM WITHIN 10 DAYS?", key:"redeem_in_10", editable:true, type:'bool'}
      {label: "TOTAL CASH OUT", key:"total_cash_out", is_function:true, type:'number'}
      {label: "TOTAL INT DUE", key:"total_interest_due", is_function:true, type:'number'}
      #TODO Calculate expected amt
      {label: "EXPECTED AMT", key:"expected_amount", is_function:true, type:'number'}
      #TODO: No longer required
      # {label: "MZ CHECK", key:"total_check", is_function:true}
      {label: "DIFFERENCE", key:"diff", is_function:true, type:'number'}

      #TODO where are notes?
      # {label: "Notes", key:"notes"}
    ]
    lien = @props.lien

    editable = React.createFactory PlainEditable
    date_picker = React.createFactory DatePicker
    checkbox = React.createFactory MUI.Checkbox
    gen_editable = (key, item, val) =>
      edit = switch(item.type)
        when 'date' then date_picker selected:moment(val), onChange:@props.onChange(item)
        when 'bool' then checkbox onCheck: @props.onChange(item), checked:!!val
        when 'number'
          val = accounting.toFixed(val, 2)
          if item.editable
            editable onBlur:@props.onChange(item), value:val
          else
            span style:{paddingLeft:'15px'}, val
        else
          if item.editable
            editable onBlur:@props.onChange(item), value:val
          else
            span style:{paddingLeft:'15px'}, val
      li key:key, className:'list-group-item',
        div null,
          span null, item.label

        div null,
          if ['date', 'bool'].indexOf(item.type) == -1
            span style:{position:'absolute'},
              if item.editable
                i className:"fa fa-pencil"
              else
                i className:"fa fa-times-circle"
          edit

    {div, h3, h1, ul, li, span, i, p} = React.DOM
    div className:'container-fluid',
      div className:'row',
        div className:'col-md-6',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "General"
            div className:'panel-body',
              ul className:'list-group',
                general_fields.map (v, k) ->
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
                li className:'list-group-item',
                  React.Factory.lien_llcs lien:lien


        div className:'col-md-6',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "Fees"
            div className:'panel-body',
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

Templates.lien_subs = React.createClass
  displayName: 'LienSubs'

  onSubState: ->

  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien
    # subs_fields = [
    #   #TODO What does this select
    #   {label: "LIEN STATUS", key:"status"}
    #   #TODO What does this toggle
    #   {label: "DON'T PAY SUBS", key:"unique_id"}
    # ]

    state_options = [
        { value: 'redeemed', label: 'Redeemed' },
        { value: 'bankruptcy', label: 'Bankruptcy' },
        { value: 'foreclosure', label: 'Foreclosure' },
        { value: 'own', label: 'Own Home' },
        { value: 'none', label: 'No Subs' },
    ];

    sub_headers = ["TYPE", "DATE", "AMT", "INT", "#", "VOID", "DATE", ""]
    sub_rows = lien.get('subs').map (v, k) ->
      [
        v.get('type'),
        moment(v.get('sub_date')).format('MM/DD/YYYY'),
        v.get('amount'),
        v.interest(),
        "",
        "",
        "",
        ""
      ]
    sub_table = Factory.table headers: sub_headers, rows: sub_rows
    select = React.createFactory Select

    div className:'panel panel-default',
      div className:'panel-heading',
        h3 className:'panel-title', "Subsequents"
      div className:'panel-body',
        ul className:'list-group',
          li className:'list-group-item',
            select name:'sub_status', value:lien.get('sub_status'), options: state_options, onChange:@props.onChange({type:'select', key:"sub_status"})
          # subs_fields.map (v, k) ->
          #   li key:k, className:'list-group-item',
          #     span className:'badge', lien[v.key]
          #     span null, v.label

          sub_table

Templates.lien_llcs = React.createClass
  displayName: 'LienLLCs'

  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    lien = @props.lien


    llc_headers = ["LLC", "START", "STOP"]
    llcs = lien.get('llcs') || []
    llc_rows = llcs.map (v, k) ->
      [
        v.get('llc'),
        moment(v.get('start')).format('MM/DD/YYYY'),
        moment(v.get('stop')).format('MM/DD/YYYY')
      ]
    llc_table = Factory.table headers: llc_headers, rows: llc_rows, height:'200px'

    llc_table


Templates.lien_checks = React.createClass
  displayName: 'LienChecks'

  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien
    receipt_headers = ["DEPOSIT DATE", "ACCOUNT", "CHECK DATE", "CHECK #", "REDEEM DATE", "CHECK AMOUNT", "PRINCIPAL", "SUBS PRINCIPAL", "CODE", "EXPECTED AMOUNT", "DIF", "NOTE"]
    receipt_rows = lien.get('checks').map (v, k) ->
      [
        moment(v.get('deposit_date')).format('MM/DD/YYYY')
        "NA"
        moment(v.get('check_date')).format('MM/DD/YYYY')
        v.get('check_number')
        v.get('')
        v.get('check_amount')
        v.get('check_principal')
        v.get('check_interest')
        v.get('type')
        v.expected_amount()
        v.expected_amount() - v.get('check_amount')
        "note"
      ]
    receipt_table = Factory.table headers: receipt_headers, rows: receipt_rows

    div className:'panel panel-default',
      div className:'panel-heading',
        h3 className:'panel-title', "Receipts"
      div className:'panel-body',
        ul className:'list-group',
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
      div className:'panel-body',
        ul className:'list-group',
          notes.map (note, key) ->
            div key:key, "BLAH"
