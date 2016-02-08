Templates.lien = React.createClass
  displayName: 'Lien'

  getInitialState: ->
    lien: undefined

  componentWillMount: ->
    query = new Parse.Query(App.Models.Lien);
    query.equalTo("unique_id", this.props.routeParams.id)
    query.include("subs")
    query.include("checks")
    query.include("annotations")
    query.find({}).then( (results) =>
      @setState lien: results[0]
    )

  onChange: (item) ->
    (data) =>
      val = switch item.type
        when 'date' then data.toDate()
        when 'bool' then $(data.target).is(':checked')
        else  arguments[1]

      lien = @state.lien
      old = lien.get(item.key)
      if typeof(old) == 'number'
        val = parseFloat(val)

      lien.set(item.key, val)
      @setState(lien:lien)

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
            RaisedButton label:"Save", onClick:@save, type:'button', disabled:!lien.dirty(), primary:true

      if @state.lien
        div className:'row',
          div className:'col-md-6',
            Factory.lien_general lien:lien, onChange:@onChange
          div className:'col-md-6',
            Factory.lien_subs lien:lien
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
      {label: "CERTIFICATE #", key:"cert_number"}

      #TODO LLCs HOW???

      #TODO there are 2 MUA ACCT's?
      {label: "MUA ACCT 1", key:"mua_account_number", editable:true}
      {label: "MUA ACCT 2", key:"mua_account_number", editable:true}
      {label: "SALE DATE", key:"sale_date", editable:true, type:'date'}
      {label: "CERT_FV", key:"cert_fv", editable:true}
      {label: "PRINCIPAL_PREMIUM", key:"premium", editable:true}
      {label: "TOTAL PAID", key:"total_paid", editable:true}
      {label: "WINNING RATE", key:"winning_bid", editable:true}
      {label: "COUNTY", key:"county", editable:true}
      {label: "ADDRESS", key:"address", editable:true}

      #TODO These are not in the excel
      {label: "CITY", key:"city", editable:true}
      {label: "STATE", key:"state", editable:true}
      {label: "ZIP", key:"zip", editable:true}
    ]

    #Second column from excel GUI
    fee_fields = [
      {label: "RECORDING DATE", key:"recording_date", editable:true, type:'date'}
      {label: "RECORDING FEE", key:"recording_fee", editable:true}
      {label: "SEARCH FEE", key:"search_fee", is_function:true, editable:true}
      {label: "FLAT RATE", key:"flat_rate", is_function:true}
      {label: "CERT INT", key:"cert_interest", is_function:true}
      {label: "2013 YEP", key:"2013_yep", editable:true}
      {label: "REDEMPTION DATE", key:"redemption_date", editable:true, type:'date'}
      {label: "AMT", key:"redemption_amt", editable:true}
      #TODO What is redeem within 10 days
      {label: "REDEEM WITHIN 10 DAYS?", key:"redeem_in_10", editable:true, type:'bool'}
      {label: "TOTAL CASH OUT", key:"total_cash_out", is_function:true}
      {label: "TOTAL INT DUE", key:"total_interest_due", is_function:true}
      #TODO Calculate expected amt
      {label: "EXPECTED AMT", key:"expected_amount", is_function:true}
      {label: "MZ CHECK", key:"total_check", is_function:true}
      {label: "DIFFERENCE", key:"diff", is_function:true}

      #TODO where are notes?
      {label: "Notes", key:"notes"}
    ]
    lien = @props.lien

    editable = React.createFactory PlainEditable
    date_picker = React.createFactory DatePicker
    checkbox = React.createFactory MUI.Checkbox
    gen_editable = (key, item, val) =>
      edit = switch(item.type)
        when 'date' then date_picker selected:moment(val), onChange:@props.onChange(item)
        when 'bool' then checkbox onCheck: @props.onChange(item), checked:!!val
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

    div className:'panel panel-default',
      div className:'panel-heading',
        h3 className:'panel-title', "Subsequents"
      div className:'panel-body',
        ul className:'list-group',
          # subs_fields.map (v, k) ->
          #   li key:k, className:'list-group-item',
          #     span className:'badge', lien[v.key]
          #     span null, v.label
          sub_table

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
