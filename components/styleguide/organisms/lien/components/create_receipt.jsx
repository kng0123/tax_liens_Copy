import Molecules from '../../../molecules'

const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const Paper = require('material-ui/lib/paper');

console.log(Molecules);

const SignIn = React.createClass({
  getInitialState: function() {
    return {
      receipt: new App.Models.LienCheck()
    }
  },
  submitForm: function(model) {
    // let action = Actions.attempt_sign_in(model)
    // this.props.dispatch(action)
    var check = App.Models.LienCheck.init_from_json(this.props.lien, model)
    this.props.lien.add_check(check)
    this.props.lien.save()
    this.props.callback()
  },

  styles: {
    paperStyle: {
      width: 300,
      margin: '20px auto',
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

    var deposit_date = undefined
    if(this.state.receipt.get('deposit_date')) {
      deposit_date = moment(this.state.receipt.get('deposit_date'))
    }
    var check_date = undefined
    if(this.state.receipt.get('check_date')) {
      check_date = moment(this.state.receipt.get('check_date'))
    }
    var redeem_date = undefined
    if(this.state.receipt.get('redeem_date')) {
      redeem_date = moment(this.state.receipt.get('redeem_date'))
    }

    return (
      <div style={paperStyle}>
        <Formsy.Form onValidSubmit={this.submitForm}>
          <FormsySelect name='type' required floatingLabelText="Receipt code">
            <MUI.Libs.MenuItem value={'combined'} primaryText="Combined" />
            <MUI.Libs.MenuItem value={'premium'} primaryText="Premium" />
            <MUI.Libs.MenuItem value={'cert_w_interest'} primaryText="Cert w/ Interest" />
            <MUI.Libs.MenuItem value={'sub_only'} primaryText="Sub only" />
            <MUI.Libs.MenuItem value={'misc'} primaryText="Misc" />
            <MUI.Libs.MenuItem value={'sold'} primaryText="Sold" />
          </FormsySelect>
          <fieldset style={{marginBottom:'0px'}} className='form-group'>
            <div>
              <label style={{marginBottom:'0px'}}>{"Deposit date"}</label>
            </div>
            <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='deposit_date' selected={deposit_date} required floatingLabelText="Deposit Date"/>
          </fieldset>
          <fieldset style={{marginBottom:'0px'}} className='form-group'>
            <div>
              <label style={{marginBottom:'0px'}}>{"Check date"}</label>
            </div>
            <Styleguide.Molecules.Forms.DatePicker width={'150px'} name='check_date' selected={check_date} required floatingLabelText="Deposit Date"/>
          </fieldset>
          <fieldset style={{marginBottom:'0px'}} className='form-group'>
            <div>
              <label style={{marginBottom:'0px'}}>{"Redeem date"}</label>
            </div>
            <Styleguide.Molecules.Forms.DatePicker width={'150px'} name='redeem_date' selected={redeem_date} floatingLabelText="Deposit Date"/>
          </fieldset>

          <FormsyText name='check_number' required hintText="Check number" value="" floatingLabelText="Check number"/>
          <FormsyText name='check_amount' required hintText="Check amount" value="" floatingLabelText="Check amount"/>
          <MUI.RaisedButton label={"Create new batch"} type={"submit"} primary={true} />
        </Formsy.Form>
      </div>
    )
  }
})

export default SignIn
