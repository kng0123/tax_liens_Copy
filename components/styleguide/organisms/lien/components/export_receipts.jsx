import Molecules from '../../../molecules'

const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const Paper = require('material-ui/lib/paper');

const ExportReceipts = React.createClass({
  getInitialState: function() {
    return {
    }
  },
  submitForm: function(model) {
    // let action = Actions.attempt_sign_in(model)
    // this.props.dispatch(action)
    var liens = this.props.liens
    var from = model.from
    var to = model.to

    var xlsx_export = new App.Utils.XLSXExport()
    xlsx_export.addRow([
      "Unique ID", "County", "Year", "LLC", "Block/Lot", "Block", "Lot",
      "Qualifier", "Adv #", "MUA Acct # / Parcel ID", "Cert #", "Lien Type",
      "List Item", "Current Owner", "Longitude", "Latitude", "Assessed Value",
      "Tax Amount", "Status", "Address", "Cert FV", "Winning Bid","Premium",
      "Total Paid","Sale Date",

      "Deposit Date", "Check Date", "Redemption Date", "Account", "Check #", "Check Amount",
      "Code", "Expected Amount", "Dif", "Check Principal", "Check Actual Interest", "Notes"
    ])

    liens.map( (lien) => {
      var county = lien.get('township').get('township')
      var owner = lien.get('owners')[0].get('llc')
      var checks = lien.get('checks')

      checks.map((check) => {
        var diff = check.get('check_amount') - check.expected_amount()
        if(!from || (from && from<check.get('deposit_date') ) ) {
          if(!to || (to && to>check.get('deposit_date') ) ) {
            xlsx_export.addRow([
              lien.get('seq_id'), county, lien.get('year'), owner, lien.get('block_lot'), lien.get('block'), lien.get('lot'),
              lien.get('qualifier'), lien.get('adv_number'), lien.get('mua_account_number'), lien.get('cert_number'), lien.get('lien_type'),
              lien.get('list_item'), lien.get('current_owner'), lien.get('longitude'), lien.get('latitude'), format_money(lien.get('assessed_value')),
              format_money(lien.get('tax_amount')), lien.get('status'), lien.get('address'), format_money(lien.get('cert_fv')), lien.get('winning_bid'), format_money(lien.get('premium')),
              format_money(lien.total_cash_out()), lien.get('sale_date'),

              check.get('deposite_date'), check.get('check_date'), check.get('redeem_date'), check.get('account'), check.get('check_number'), format_money(check.get('check_amount')),
              check.get('type'), format_money(check.expected_amount()), format_money(diff), "", "", ""
            ])
          }
        }
      })
    })

    xlsx_export.save()
  },

  styles: {
    paperStyle: {
      width: '100%',
      padding: 20
    },
    switchStyle: {
      marginBottom:16
    },
    submitStyle: {
      marginTop: 32
    },
    linksStyle: {
      marginTop: 10
    }
  },

  updateFormState: function(model) {
    this.setState({model: model})
  },

  render: function () {
    let {paperStyle, switchStyle, submitStyle, linksStyle } = this.styles;
    let {div, span, h3, ul, li, fieldset, label} = React.DOM
    let link = React.createFactory( ReactRouter.Link )

    let error = <div></div>
    if( this.props.form['sign_in'] && this.props.form['sign_in'].error ) {
      error = <div className="alert alert-danger" role="alert" style={{marginBottom:0}}>
        <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
        <span className="sr-only">{"Error:"}</span>
        {"Invalid username/password"}
      </div>
      }


    var from = new Date()
    var to = new Date()

    var form_rows = [
      {
        label: 'From',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='from' value={from} required/>
      },
      {
        label: 'To',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='to' value={to} required/>
      }
    ]
    var form_body = form_rows.map( (row, key) => {
        var className="form-group row"
        return (<div className={className} key={key}>
          <label htmlFor="type" className="col-sm-3 form-control-label">{row.label}</label>
          <div className="col-sm-9">
            {row.element}
          </div>
        </div>)
    })

    return (
      <div style={paperStyle}>
        <Formsy.Form onValidSubmit={this.submitForm} onChange={this.updateFormState}>
          {form_body}
          <MUI.RaisedButton key={"end"} label={"Export receipts"} type={"submit"} primary={true} />
        </Formsy.Form>
      </div>
    )
  }
})

var accounting = require('accounting')
var format_money = function(money) {
  var acc_format = {symbol : "", decimal : ".", precision : 2, format: "%s%v"}
  return accounting.formatMoney(money/100, acc_format)
}

export default ExportReceipts
