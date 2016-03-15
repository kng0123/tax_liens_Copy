var Formsy = require('formsy-react');
var MyOwnInput = React.createClass({

  // Add the Formsy Mixin
  mixins: [Formsy.Mixin],

  // setValue() will set the value of the component, which in
  // turn will validate it and the rest of the form
  getInitialState: function() {
    var val = ""
    var date_string = ""
    if (!this.props.value || this.props.value == 'Empty') {
      val = ""
    } else {
      val = moment(this.props.value).format('MM/DD/YYYY')
      date_string = moment(val).format('MM/DD/YYYY')
    }
    return {
      value: val,
      date_string: date_string
    }
  },
  changeValue: function(event) {
    var date_string = moment(event.target.value)
    var year = moment(event.target.value).year()
    if( year < 2002) {
      date_string.year(moment().year())
    }

    this.setState({
      value: event.target.value,
      date_string: date_string.format('MM/DD/YYYY')
    })
    event.target.value = date_string.format('MM/DD/YYYY')
    if(this.props.onChange) {
      this.props.onChange(event)
    }
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

    return (
      <div className={className} style={style}>
        <input type="text" className='form-control' value={this.state.value}  onChange={this.changeValue} onBlur={this.updateValue}/>
        <span>{this.state.date_string}</span>
        <span>{errorMessage}</span>
      </div>
    );
  }
});

export default MyOwnInput
