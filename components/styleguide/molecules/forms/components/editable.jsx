var Editable = React.createClass({
  getInitialState: function() {
    return {
      value: this.props.value,
      start: false
    }
  },
  onBlur: function(event) {
    if( this.state.value || this.state.value == 0 ){
      let value = this.state.value
      try {
        value = eval(this.state.value)
      } catch( e) {

      }
      this.refs.editable.value = value
      this.setState({value:value})
      this.props.onBlur(value)
    }
  },
  onChange: function(event){
    let value = this.refs.editable.value
    if(this.state.start) {
      value = value.slice(-1)
      this.refs.editable.value = value
    }
    this.setState({value:value, start:false})
  },
  onFocus: function() {
    this.setState({start:true})
  },
  onKeyDown: function(event){
    let keyCodes = [37, 38, 39, 40]
    if (keyCodes.indexOf(event.keyCode) != -1) {
      this.setState({start:false})
    }
  },
  render: function() {
    return <input type="text" onKeyDown={this.onKeyDown} onFocus={this.onFocus} ref="editable" onChange={this.onChange} onBlur={this.onBlur} defaultValue={this.state.value} />
  }
})

export default Editable
