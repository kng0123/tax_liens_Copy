import Molecules from '../../../molecules'
var accounting = require('accounting')
const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const Paper = require('material-ui/lib/paper');

const EditReceipt = React.createClass({
  getInitialState: function() {
    return {
      receipt: new App.Models.LienCheck(),
      model: {}
    }
  },
  submitForm: function(model) {
    // let action = Actions.attempt_sign_in(model)
    // this.props.dispatch(action)
    var receipt = this.props.receipt
    var callback = this.props.callback
    Object.keys(model).map(function(key) {
      if(key == 'check_amount') {
         return receipt.set(key,Math.round(accounting.unformat(model.check_amount) * 100))
      } else {
        return receipt.set(key, model[key])
      }
    })
    return receipt.save().then(function(){
      callback()
    }).fail(function() {
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
    this.setState({model: model})
  },

  render: function () {
    let {paperStyle, switchStyle, submitStyle, linksStyle } = this.styles;
    let {div, span, h3, ul, li, fieldset, label} = React.DOM
    let link = React.createFactory( ReactRouter.Link )

    let error = <div></div>

    var check = this.props.receipt
    var deposit_date = undefined
    if(check.get('deposit_date')) {
      deposit_date = (check.get('deposit_date'))
    }
    var check_date = undefined
    if(check.get('check_date')) {
      check_date = (check.get('check_date'))
    }
    var redeem_date = undefined
    if(check.get('redeem_date')) {
      redeem_date = (check.get('redeem_date'))
    }

    var code_options = BackboneApp.Models.Receipt.code_options()
    var sub_options = this.props.lien.get('subsequents').models.map( (sub) => {
      return {label: sub.name(), value:sub}
    })

    var check_amount = accounting.formatMoney(check.amount()/100, {symbol : "$", decimal : ".", precision : 2, format: "%s%v"})
    var expected_amount = accounting.formatMoney(check.expected_amount()/100, {symbol : "$", decimal : ".", precision : 2, format: "%s%v"})
    var form_rows = [
      {
        label: 'Code',
        element: <Styleguide.Molecules.Forms.ReactSelect value={check.get('receipt_type')} options={code_options} required name={"receipt_type"}/>,
        helper: <span><strong>Principal: </strong><span>{expected_amount}</span></span>
      },
        {
          label: 'Sub',
          filter: (function(){ return this.state.model.type != 'sub_only'}).bind(this),
          element: <Styleguide.Molecules.Forms.ReactSelect value={check.get('sub')} renderValue={function(sub){if(sub){return sub.name()}}} options={sub_options} return name={"sub"}/>
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
        element: <FormsyText name='check_number' required hintText="Check number" value={check.get('check_number')}/>
      },
      {
        label: 'Check amount',
        element: <FormsyText name='check_amount' type="text" value={check_amount} required hintText="Check amount"/>
      }
    ]
    var form_body = form_rows.map( (row, key) => {
        var className="form-group row"
        if(row.filter && row.filter()) {
          return
        }
        return (<div className={className} key={key}>
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
          {form_body}
          <MUI.RaisedButton key={"end"} label={"Save receipt"} type={"submit"} primary={true} />
        </Formsy.Form>
      </div>
    )
  }
})

export default EditReceipt
