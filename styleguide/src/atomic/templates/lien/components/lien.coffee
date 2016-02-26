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
        div className:'col-lg-12', ""
          # Factory.lien_search @props
      # div className:'row',
      #   div className:'col-lg-12',
      #     div className:'container-fluid',
      #       h1 null, "LIEN #{@state.lien.get('unique_id')}"

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

  render: ->
    {div} = React.DOM
    fi = React.createFactory MUI.Libs.FontIcons
    iconStyles = {
      color: '#FB8C00'
      marginRight: 10,
    };
    div null,
      fi className:"muidocs-icon-action-home material-icons orange600", style:iconStyles, "face"
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
      amt: sub.get('amount'),
      int: sub.interest(),
      number: "",
      actions: {g:2}
    }
  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    lien = @props.lien

    state_options = [
        { value: 'redeemed', label: 'Redeemed' },
        { value: 'bankruptcy', label: 'Bankruptcy' },
        { value: 'foreclosure', label: 'Foreclosure' },
        { value: 'own', label: 'Own Home' },
        { value: 'none', label: 'No Subs' },
    ];

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
      minHeight:500
    }
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
    llc_table = Factory.table headers: llc_headers, rows: llc_rows, height:'50px'

    llc_table


Templates.lien_checks = React.createClass
  displayName: 'LienChecks'

  rowGetter: (i) ->
    receipt = @props.lien.get('checks')[i]
    {
      deposit_date: moment(receipt.get('deposit_date')).format('MM/DD/YYYY')
      account: "NA"
      check_date: moment(receipt.get('check_date')).format('MM/DD/YYYY')
      check_number: receipt.get('check_number')
      redeem_date: receipt.get('')
      check_amount: receipt.get('check_amount')
      principal: receipt.get('check_principal')
      subs: receipt.get('check_interest')
      code: receipt.get('type')
      expected_amt: receipt.expected_amount()
      dif: receipt.expected_amount() - receipt.get('check_amount')
      note: "note"
    }

  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien
    columns = [
      {name:"Deposit date", key:'deposit_date'}
      {name:"Account", key:'account'}
      {name:"Check date", key:'check_date'}
      {name:"Check #", key:'check_number'}
      {name:"Redeem date", key:'redeem_date'}
      {name:"Check amount", key:'check_amount'}
      {name:"Principal", key:'principal'}
      {name:"Subs Principal", key:'subs'}
      {name:"Code", key:'code'}
      {name:"Expected Amt", key:'expected_amt'}
      {name:"Dif", key:'dif'}
      {name:"Note", key:'note'}
    ]

    receipt_table = React.createFactory(ReactDataGrid) {
      columns:columns
      enableCellSelect: true
      rowGetter:@rowGetter
      rowsCount:lien.get('checks').length
      minHeight:500
    }

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
