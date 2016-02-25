const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const MenuItem = require('material-ui/lib/menus/menu-item');
const Paper = require('material-ui/lib/paper');

const Form = React.createClass({

  getInitialState: function () {
    return {
      canSubmit: false
    };
  },

  errorMessages: {
    wordsError: "Please only use letters"
  },

  enableButton: function () {
    this.setState({
      canSubmit: true
    });
  },

  disableButton: function () {
    this.setState({
      canSubmit: false
    });
  },

  submitForm: function (model) {
    // Submit your validated form
    console.log("Model: ", model);
  },

  styles: {
    paperStyle: {
      width: 300,
      margin: 20,
      padding: 20
    },
    switchStyle: {
      marginBottom:16
    },
    submitStyle: {
      marginTop: 32
    }
  },

  render: function () {
    let { wordsError, numericError, urlError } = this.errorMessages;
    let {paperStyle, switchStyle, submitStyle } = this.styles;
    return (
      <Paper style={paperStyle}>
        <Formsy.Form
          onValid={this.enableButton}
          onInvalid={this.disableButton}
          onValidSubmit={this.submitForm}
        >

          <FormsyText
           name='name'
           validations='isWords'
           validationError={wordsError}
           required
           hintText="What is your name?"
           value="Bob"
           floatingLabelText="Name"
          />

          <FormsySelect
            name='frequency'
            required
            floatingLabelText="How often?">
            <MenuItem value={'never'} primaryText="Never" />
            <MenuItem value={'nightly'} primaryText="Every Night" />
            <MenuItem value={'weeknights'} primaryText="Weeknights" />
          </FormsySelect>

          <FormsyDate
            name='date'
            required
            floatingLabelText="Date"
          />

          <FormsyTime
            name='time'
            required
            floatingLabelText="Time"
          />

          <FormsyCheckbox
            name='agree'
            label="Do you agree to disagree?"
            defaultChecked={true}
          />

          <FormsyToggle
            name='toggle'
            label="Toggle"
          />

          <FormsyRadioGroup name="shipSpeed" defaultSelected="not_light">
            <FormsyRadio
              value="light"
              label="prepare for light speed"
            />
            <FormsyRadio
              value="not_light"
              label="light speed too slow"
            />
            <FormsyRadio
              value="ludicrous"
              label="go to ludicrous speed"
              disabled={true}
            />
          </FormsyRadioGroup>

          <RaisedButton
            type="submit"
            label="Submit"
            disabled={!this.state.canSubmit}
          />
        </Formsy.Form>
      </Paper>
    );
  }
});

export default Form;
