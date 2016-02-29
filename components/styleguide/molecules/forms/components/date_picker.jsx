var Formsy = require('formsy-react');
var MyOwnInput = React.createClass({

  // Add the Formsy Mixin
  mixins: [Formsy.Mixin],

  // setValue() will set the value of the component, which in
  // turn will validate it and the rest of the form
  changeValue: function (event) {
    this.setValue(moment(event).toDate());
  },

  render: function () {

    // Set a specific className based on the validation
    // state of this component. showRequired() is true
    // when the value is empty and the required prop is
    // passed to the input. showError() is true when the
    // value typed is invalid
    var className = this.showRequired() ? 'required' : this.showError() ? 'error' : null;


    // An error message is returned ONLY if the component is invalid
    // or the server has returned an error message
    var errorMessage = this.getErrorMessage();
    var style = {
      width: this.props.width || '100px',
      marginTop:"10px"
    }
    var val = ""
    if(!this.getValue()) {
      val = ""
    } else {
      val = moment(this.getValue())
    }

    return (
      <div className={className} style={style}>
        <DatePicker className='form-control datepicker' selected={val} onChange={this.changeValue}/>
        <span>{errorMessage}</span>
      </div>
    );
  }
});

export default MyOwnInput
