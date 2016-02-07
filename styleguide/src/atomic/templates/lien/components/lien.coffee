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
      lien.set(item.key, val)
      @setState(lien:lien)

  render: ->
    {div, h3, h1, ul, li, span, i} = React.DOM
    Factory = React.Factory

    Table = React.createFactory MUI.Table
    TableHeader = React.createFactory MUI.TableHeader
    TableRow = React.createFactory MUI.TableRow
    TableHeaderColumn = React.createFactory MUI.TableHeaderColumn
    TableBody = React.createFactory MUI.TableBody
    TableRowColumn = React.createFactory MUI.TableRowColumn
    RaisedButton = React.createFactory MUI.RaisedButton

    lien = @state.lien
    if !lien
      return div null, ""

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

      #TODO These are in the excel
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

    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    subs_fields = [
      #TODO What does this select
      {label: "LIEN STATUS", key:"status"}
      #TODO What does this toggle
      {label: "DON'T PAY SUBS", key:"unique_id"}
    ]

    sub_table_state = {
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
      height: '600px',
    };

    sub_table_props =
      height: sub_table_state.height
      fixedHeader: sub_table_state.fixedHeader
      fixedFooter: sub_table_state.fixedFooter
      selectable: sub_table_state.selectable
      multiSelectable: sub_table_state.multiSelectable
      onRowSelection: ->

    sub_table = Table sub_table_props,
      TableHeader adjustForCheckbox:sub_table_state.adjustForCheckbox, enableSelectAll:sub_table_state.enableSelectAll, displayRowCheckbox:sub_table_state.displayRowCheckbox, displaySelectAll:false,
        TableRow null,
          TableHeaderColumn null, "TYPE"
          TableHeaderColumn null, "DATE"
          TableHeaderColumn null, "AMT"
          TableHeaderColumn null, "INT"
          TableHeaderColumn null, "#"
          #TODO What does this toggle do?
          TableHeaderColumn null, "VOID"
          TableHeaderColumn null, "DATE"
          #TODO WHAT DOES THE X Action do?
          TableHeaderColumn null, ""
      TableBody deselectOnClickaway:sub_table_state.deselectOnClickaway, showRowHover:sub_table_state.showRowHover, stripedRows:sub_table_state.stripedRows, displayRowCheckbox:sub_table_state.displayRowCheckbox,
        lien.get('subs').map (v, k) ->
          style = {padding:0, textAlign:'center'}
          TableRow key:k,
            TableRowColumn  style:style, v.get('type')
            TableRowColumn  style:style, moment(v.get('sub_date')).format('MM/DD/YYYY')
            TableRowColumn  style:style, v.get('amount')
            TableRowColumn  style:style, v.interest()
            TableRowColumn style:style, ""
            TableRowColumn  style:style, ""
            #TODO Why are there 2 dates
            TableRowColumn  style:style, ""
            TableRowColumn  style:style, ""

    receipt_table_state = {
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
      height: '600px',
    };

    receipt_table_props =
      height: sub_table_state.height
      fixedHeader: sub_table_state.fixedHeader
      fixedFooter: sub_table_state.fixedFooter
      selectable: sub_table_state.selectable
      multiSelectable: sub_table_state.multiSelectable
      onRowSelection: ->
    receipt_table = Table sub_table_props,
      TableHeader adjustForCheckbox:receipt_table_state.adjustForCheckbox, enableSelectAll:receipt_table_state.enableSelectAll, displayRowCheckbox:receipt_table_state.displayRowCheckbox, displaySelectAll:false,
        TableRow null,
          TableHeaderColumn null, "DEPOSIT DATE"
          TableHeaderColumn null, "ACCOUNT"
          TableHeaderColumn null, "CHECK DATE"
          TableHeaderColumn null, "CHECK #"
          TableHeaderColumn null, "REDEEM DATE"
          TableHeaderColumn null, "CHECK AMOUNT"
          TableHeaderColumn null, "PRINCIPAL"
          TableHeaderColumn null, "SUBS PRINCIPAL"
          TableHeaderColumn null, "CODE"
          TableHeaderColumn null, "EXPECTED AMOUNT"
          TableHeaderColumn null, "DIF"
          TableHeaderColumn null, "NOTE"

      TableBody deselectOnClickaway:receipt_table_state.deselectOnClickaway, showRowHover:receipt_table_state.showRowHover, stripedRows:receipt_table_state.stripedRows, displayRowCheckbox:receipt_table_state.displayRowCheckbox,
        lien.get('checks').map (v, k) ->
          style = {padding:0, textAlign:'center'}
          TableRow key:k,
            TableRowColumn style:style, moment(v.get('deposit_date')).format('MM/DD/YYYY')
            TableRowColumn style:style, "NA"
            TableRowColumn style:style, moment(v.get('check_date')).format('MM/DD/YYYY')
            TableRowColumn style:style, v.get('check_number')
            TableRowColumn style:style, v.get('')
            TableRowColumn style:style, v.get('check_amount')
            TableRowColumn style:style, v.get('check_principal')
            TableRowColumn style:style, v.get('check_interest')
            TableRowColumn style:style, "code"
            TableRowColumn style:style, "expected"
            TableRowColumn style:style, "dif"
            TableRowColumn style:style, "note"


    editable = React.createFactory PlainEditable
    date_picker = React.createFactory DatePicker
    checkbox = React.createFactory MUI.Checkbox
    gen_editable = (key, item, val) =>
      edit = switch(item.type)
        when 'date' then date_picker selected:moment(val), onChange:@onChange(item)
        when 'bool' then checkbox onCheck: @onChange(item), checked:!!val
        else editable onBlur:@onChange(item), value:val
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



    div className:'container-fluid',
      div className:'row',
        div className:'col-lg-12',
          h1 null, "LIEN #{@state.lien.get('unique_id')}"
      if @state.lien
        div className:'row',
          div className:'col-md-3',
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


          div className:'col-md-3',
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


          div className:'col-md-6',
            div className:'panel panel-default',
              div className:'panel-heading',
                h3 className:'panel-title', "Subsequents"
              div className:'panel-body',
                ul className:'list-group',
                  subs_fields.map (v, k) ->
                    li key:k, className:'list-group-item',
                      span className:'badge', lien[v.key]
                      span null, v.label
                  sub_table

          div className:'col-md-12',
            div className:'panel panel-default',
              div className:'panel-heading',
                h3 className:'panel-title', "Receipts"
              div className:'panel-body',
                ul className:'list-group',
                  receipt_table
      else
        div null, ""
