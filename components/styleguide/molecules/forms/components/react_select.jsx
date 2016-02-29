import {default as Select} from 'react-select'

var ReactSelect = React.createClass({
  mixins: [Formsy.Mixin],

  changeValue: function(event) {
    this.setValue(event.value)
  },

  render: function() {
    var className = this.showRequired() ? 'required' : this.showError() ? 'error' : null;
    var val = this.getValue()
    return (<div className={className}>
      <Select
          value={val}
          options={this.props.options}
          onChange={this.changeValue}
          valueRenderer={this.props.renderValue}
      />
    </div>)
  }
})

export default ReactSelect
