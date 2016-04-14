import Molecules from '../../../molecules'
var accounting = require('accounting')
const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const Paper = require('material-ui/lib/paper');

const CreateReceipt = React.createClass({
  getInitialState: function() {
    return {
      receipt: new BackboneApp.Models.Receipt(),
      model: {}
    }
  },
  submitForm: function(model) {
    // let action = Actions.attempt_sign_in(model)
    // this.props.dispatch(action)

    model.lien_id = this.props.lien.get('id')
    var new_check = new BackboneApp.Models.Receipt(model)
    var res = new_check.save()
    var self = this
    res.success(function() {
      self.props.callback()
    })
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
    if(model.target) {
      return
    }
    this.setState({model: model})
    return model
  },

  render: function () {
    let {paperStyle, switchStyle, submitStyle, linksStyle } = this.styles;
    let {div, span, h3, ul, li, fieldset, label} = React.DOM
    let link = React.createFactory( ReactRouter.Link )

    let error = <div></div>

    var deposit_date = undefined
    if(this.state.receipt.get('deposit_date')) {
      deposit_date = (this.state.receipt.get('deposit_date'))
    }
    var check_date = undefined
    if(this.state.receipt.get('check_date')) {
      check_date = (this.state.receipt.get('check_date'))
    }
    var redeem_date  = moment().format('MM/DD/YYYY')
    if(this.props.lien.get('redemption_date')) {
      redeem_date = (this.props.lien.get('redemption_date'))
    }


    var code_options = BackboneApp.Models.Receipt.code_options()
    var account_options = BackboneApp.Models.Receipt.account_options()
    var sub_options = this.props.lien.get('subsequents').models.map( (sub) => {
      return {label: sub.name(), value:sub}
    })
    var expected_amount = accounting.formatMoney(this.props.lien.receipt_expected_amount(this.state.model.receipt_type)/100, {symbol : "$", decimal : ".", precision : 2, format: "%s%v"})
    var form_rows = [
      {
        label: 'Code',
        element: <Styleguide.Molecules.Forms.ReactSelect options={code_options} required name={"receipt_type"}/>,
        helper: <span><strong>Principal: </strong><span>{expected_amount}</span></span>
      },
      {
        label: 'Account Type',
        element: <Styleguide.Molecules.Forms.ReactSelect options={account_options} required name={"account_type"}/>
      },
        {
          label: 'Sub',
          filter: (function(){ return this.state.model.receipt_type != 'sub_only'}).bind(this),
          element: <Styleguide.Molecules.Forms.ReactSelect renderValue={function(sub){if(sub){return sub.name()}}} options={sub_options} name={"sub"}/>
        },
        {
          label: 'Principal',
          filter: (function(){ return this.state.model.receipt_type != 'misc'}).bind(this),
          element: <FormsyText name='misc_principal' required hintText="Principal amount" value=""/>
        },
      {
        label: 'Deposit Date',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='deposit_date' value={deposit_date} required/>
      },
      {
        label: 'Check Date',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='check_date' value={check_date} required/>
      },
      {
        label: 'Redeem Date',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='redeem_date' value={redeem_date}/>
      },
      {
        label: 'Check number',
        element: <FormsyText name='check_number' required hintText="Check number" value=""/>
      },
      {
        label: 'Check amount',
        element: <FormsyText name='check_amount' required hintText="Check amount" value=""/>
      }
    ]
    var form_body = form_rows.map( (row, key) => {
        var className="form-group row"
        if(row.filter && row.filter()) {
          return
        }
        return (<div style={{marginBottom:'5px'}} className={className} key={key}>
          <label htmlFor="type" className="col-sm-3 form-control-label">{row.label}</label>
          <div className="col-sm-9">
            {row.element}
            {row.helper}
          </div>
        </div>)
    }).filter(function(item){return item})

    return (
      <div style={paperStyle}>
        <Formsy.Form onValidSubmit={this.submitForm} onChange={this.updateFormState}>
          <div>
            <div style={{width:'45%', float:'left'}}>
              {form_body}
            </div>
            <div style={{width:'45%', float:'right'}}>
              <div className="form-group row">
                <label htmlFor="type" className="col-sm-3 form-control-label">Note</label>
                <div className="col-sm-9">
                  <Styleguide.Molecules.Forms.TextArea name="note" rows={5} value=""/>
                </div>
              </div>
            </div>
          </div>
          <div style={{clear:'both'}}>
            <MUI.RaisedButton key={"end"} label={"Create receipt"} type={"submit"} primary={true} />
          </div>
        </Formsy.Form>
      </div>
    )
  }
})

export default CreateReceipt
