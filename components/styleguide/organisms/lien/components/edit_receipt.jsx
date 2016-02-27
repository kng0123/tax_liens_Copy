import Molecules from '../../../molecules'

const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const Paper = require('material-ui/lib/paper');

console.log(Molecules);

const SignIn = React.createClass({
  submitForm: function(model) {
    let action = Actions.attempt_sign_in(model)
    this.props.dispatch(action)
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
    let {div, span, h3, ul, li} = React.DOM
    let link = React.createFactory( ReactRouter.Link )

    let error = <div></div>
    if( this.props.form['sign_in'] && this.props.form['sign_in'].error ) {
      error = <div className="alert alert-danger" role="alert" style={{marginBottom:0}}>
        <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
        <span className="sr-only">{"Error:"}</span>
        {"Invalid username/password"}
      </div>
      }

    return (
      <div style={paperStyle}>
        <Formsy.Form onValidSubmit={this.submitForm}>
          <FormsySelect name='receipt_code' required floatingLabelText="Receipt code">
            <MUI.Libs.MenuItem value={'never'} primaryText="Never" />
            <MUI.Libs.MenuItem value={'nightly'} primaryText="Every Night" />
            <MUI.Libs.MenuItem value={'weeknights'} primaryText="Weeknights" />
          </FormsySelect>
          <Styleguide.Molecules.Forms.DatePicker name='deposit_date' value={moment(this.props.receipt.get('deposit_date')).format('YYYY-MM-DD')} required floatingLabelText="Deposit Date"/>
          <Styleguide.Molecules.Forms.DatePicker name='check_date'   value={moment(this.props.receipt.get('check_date')).format('YYYY-MM-DD')} required floatingLabelText="Check Date"/>
          <Styleguide.Molecules.Forms.DatePicker name='redeem_date'  value={moment(this.props.receipt.get('redeem_date')).format('YYYY-MM-DD')} required floatingLabelText="Redeem Date"/>

          <FormsyText name='check_number' required hintText="Check number" value="" floatingLabelText="Check number"/>
          <FormsyText name='check_amount' required hintText="Check amount" value="" floatingLabelText="Check amount"/>

        </Formsy.Form>
      </div>
    )
  }
})

export default SignIn
