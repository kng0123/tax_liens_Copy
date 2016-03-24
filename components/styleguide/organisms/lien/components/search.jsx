var Search = React.createClass({
  getInitialState: function(){
    var ts = new BackboneApp.Collections.TownshipCollection()
    ts.fetch()
    return {
      townships: ts
    }
  },
  render: function() {
    return <SearchHelper {...this.props} townships={this.state.townships} />
  }
})

var SearchHelper = React.createBackboneClass({
  displayName: 'LienSearch',

  mixins: [
      React.BackboneMixin("townships")
  ],

  contextTypes: {
    router: React.PropTypes.object
  },

  getInitialState: function(){
    return {
      data: Object.assign( {}, this.props.search)
    }
  },

  townshipSelect: function() {
    return this.props.townships.models.map(function(township){
      return {label: township.get('name'), value:township.get('name')}
    })
  },

  componentWillReceiveProps: function(props){
    var self = this
    this.setState({data: props.search})
  },

  onChange: function(event) {
    if( event.label) {
      var data = this.state.data
      data['township'] = event.value
      this.setState({ data: data})
    } else {
      var name = event.target.name
      var val = event.target.value

      data = this.state.data
      data[name] = val
      this.setState({ data: data})
    }
  },

  onSubmit: function(e) {
    e.stopPropagation()
    e.preventDefault()
    this.context.router.push({
      pathname: '/lien',
      query: this.state.data
    })
    this.props.dispatch({type:'SEARCH', data:this.state.data})
    return false
  },

  render: function() {
    var inputs = [
      {label: "Block", type:'text', key:'block'}
      , {label: "Lot", type:'text', key:'lot'}
      , {label: "Qual", type:'text', key:'qualifier'}
       ,{label: "Certificate #", type:'text', key:'cert'}
      ,{label: "Sale year", type:'text', key:'sale_year'}
      ,{  label: "Township", type:'text', key:'township'}
      ,{label: "Case #", type:'text', key:'case'}
      ,{label: "Lien ID", type:'text', key:'id'}
    ]

    var self = this
    var input_els = inputs.map(function(item, index) {
      var el = <input onChange={self.onChange} style={{width:'130px'}} type={item.type} name={item.key} value={self.state.data[item.key]} className='form-control' />
      if(item.key == 'township') {
        el = <Select style={{width:'130px'}} value={self.state.data[item.key]} name={item.key} options={self.townshipSelect()} onChange={self.onChange} />
      }
      return <div key={index} className='form-group'>
        <div style={{display:'block'}}>
          <div>
            <span>{item.label}</span>
          </div>
          {el}
        </div>
      </div>
    })

    return <form className='form-inline' onSubmit={this.onSubmit}>
      {input_els}
      <button type='submit' style={{marginTop:'20px', marginLeft:'10px'}} className='btn btn-primary'>Go</button>
    </form>
  }
})

export default Search
