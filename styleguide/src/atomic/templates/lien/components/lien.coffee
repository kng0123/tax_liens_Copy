Templates.lien = React.createClass
  displayName: 'Lien'

  getInitialState: ->
    lien: {}

  componentWillMount: ->
    Lien = Parse.Object.extend("Lien");
    query = new Parse.Query(Lien);
    query.equalTo("objectId", this.props.routeParams.id)
    query.find({
    	success : (results) =>
    		@setState lien: results[0]._toFullJSON()
    	,
    	error : (obj, error) ->
    })

  render: ->
    {div, h3, h1, ul, li, span} = React.DOM
    Factory = React.Factory

    Table = React.createFactory MUI.Table
    TableHeader = React.createFactory MUI.TableHeader
    TableRow = React.createFactory MUI.TableRow
    TableHeaderColumn = React.createFactory MUI.TableHeaderColumn
    TableBody = React.createFactory MUI.TableBody
    TableRowColumn = React.createFactory MUI.TableRowColumn
    RaisedButton = React.createFactory MUI.RaisedButton

    lien = @state.lien

    #First column from excel GUI
    general_fields = [
      {label: "Lien ID", key:"unique_id"}
      {label: "BLOCK/LOT/QUAL", key:"block_lot"}
      {label: "CERTIFICATE #", key:"cert_number"}

      #TODO LLCs HOW???

      #TODO there are 2 MUA ACCT's?
      {label: "MUA ACCT 1", key:"mua_account_number"}
      {label: "MUA ACCT 2", key:"mua_account_number"}
      {label: "SALE DATE", key:"sale_date"}
      {label: "CERT_FV", key:"cert_fv"}
      {label: "PRINCIPAL_PREMIUM", key:"premium"}
      {label: "TOTAL PAID", key:"total_paid"}
      {label: "WINNING RATE", key:"winning_bid"}
      {label: "COUNTY", key:"county"}
      {label: "ADDRESS", key:"address"}

      #TODO These are in the excel
      {label: "CITY", key:"county"}
      {label: "STATE", key:"county"}
      {label: "ZIP", key:"county"}
    ]

    #Second column from excel GUI
    fee_fields = [
      {label: "RECORDING DATE", key:"recording_date"}
      {label: "RECORDING FEE", key:"recording_fee"}
      {label: "SEARCH FEE", key:"search_fee"}
      {label: "FLAT RATE", key:"flat_rate"}
      {label: "CERT INT", key:"cert_int"}
      {label: "2013 YEP", key:"2013_yep"}
      {label: "REDEMPTION DATE", key:"redemption_date"}
      {label: "AMT", key:"redemption_amt"}
      #TODO What is redeem within 10 days
      {label: "REDEEM WITHIN 10 DAYS?", key:"total_cash_out"}
      {label: "TOTAL CASH OUT", key:"total_cash_out"}
      {label: "TOTAL INT DUE", key:"total_int_due"}
      #TODO Calculate expected amt
      {label: "EXPECTED AMT", key:"total_int_due"}
      {label: "MZ CHECK", key:"mz_check"}
      {label: "DIFFERENCE", key:"total_int_due"}

      #TODO where are notes?
      {label: "Notes", key:"notes"}
    ]

    #Third column from excel gui
    lien.subs = [{type:'check'}, {type:'check'}]
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
        lien.subs.map (v, k) ->
          TableRow key:k,
            TableRowColumn null, v.type
            TableRowColumn null, v.date
            TableRowColumn null, v.amount
            TableRowColumn null, v.int
            TableRowColumn null, v.check_number
            TableRowColumn null, v.void
            #TODO Why are there 2 dates
            TableRowColumn null, v.date
            TableHeaderColumn null, ""

    div className:'container-fluid',
      div className:'row',
        div className:'col-lg-12',
          h1 null, "LIEN #{@state.lien.unique_id}"
      div className:'row',
        div className:'col-md-3',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "General"
            div className:'panel-body',
              ul className:'list-group',
                general_fields.map (v, k) ->
                  li key:k, className:'list-group-item',
                    span className:'badge', lien[v.key]
                    span null, v.label

        div className:'col-md-3',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "Fees"
            div className:'panel-body',
              ul className:'list-group',
                fee_fields.map (v, k) ->
                  li key:k, className:'list-group-item',
                    span className:'badge', lien[v.key]
                    span null, v.label

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
            div className:'panel-body', "Panel content"
