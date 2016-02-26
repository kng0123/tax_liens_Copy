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
      <Paper style={paperStyle}>
        <Formsy.Form onValidSubmit={this.submitForm}>
          <h3 className='strong text-center text-grey'>{"Sign In"}</h3>
          {error}
          <FormsyText name='username' required hintText="What is your name?" value="" floatingLabelText="Username"/>
          <FormsyText name='password' type="password" required hintText="What is your password?" value="" floatingLabelText="Password"/>
          <RaisedButton type="submit" label="Submit"/>

        </Formsy.Form>
        <ul className='list-unstyled' style={linksStyle}>
          <li className='text-center'>
            <ReactRouter.Link to='/auth/sign_up'>{"Not registered? Sign up"}</ReactRouter.Link>
          </li>
        </ul>
      </Paper>
    )
  }
})

export default SignIn
