import {default as TextareaAutosize} from 'react-textarea-autosize'

var TextArea = React.createClass({
  mixins: [Formsy.Mixin],

  changeValue: function(event) {
    this.setValue(event.target.value)
  },

  render: function() {
    var className = this.showRequired() ? 'required' : this.showError() ? 'error' : null;
    var val = this.getValue()
    var errorMessage = this.getErrorMessage();

    return (<div className={className}>
      <TextareaAutosize
        name={this.props.name}
        value={val}
        style={{boxSizing: 'border-box', width:'300px'}}
        minRows={10}
        maxRows={15}
        defaultValue={this.props.value}
        onChange={this.changeValue}
      />
    </div>)
  }
})

export default TextArea
