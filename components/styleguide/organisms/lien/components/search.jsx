var _ = require('underscore')
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
      data: Object.assign( {r:Date.now()}, this.props.search)
    }
  },

  clearFields: function() {
    var data = this.state.data;
    data = _.mapObject(data, function(val, key) {
      return "";
    });
    this.setState({data: data})
  },

  townshipSelect: function() {
    return this.props.townships.models.map(function(township){
      return {label: township.get('name'), value:township.get('name')}
    })
  },

  componentWillReceiveProps: function(props){
    var self = this
    // this.setState({data: props.search})
  },

  onChange: function(event) {
    if(!event) {
      var data = this.state.data
      data['township'] = ""
      this.setState({ data: data})
      return
    }
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
      pathname: '/app/lien',
      query: this.state.data
    })
    this.props.dispatch({type:'SEARCH', data:this.state.data})
    return false
  },

  render: function() {
    var inputs = [
      {label: "Block", type:'text', key:'block', width:'100px'}
      , {label: "Lot", type:'text', key:'lot', width:'100px'}
      , {label: "Qual", type:'text', key:'qualifier', width:'100px'}
      , {label: "Certificate #", type:'text', key:'cert', width:'100px'}
      , {label: "Sale year", type:'text', key:'sale_year', width:'100px'}
      , {label: "Township", type:'text', key:'township', width:'130px'}
      , {label: "Case #", type:'text', key:'case', width:'100px'}
      , {label: "Lien ID", type:'text', key:'id', width:'100px'}
      , {label: "Address", type:'text', key:'address', width:'150px'}
    ]

    var self = this
    var input_els = inputs.map(function(item, index) {
      var el = <input onChange={self.onChange} style={{width:'100%'}} type={item.type} name={item.key} value={self.state.data[item.key]} className='form-control' />
      if(item.key == 'township') {
        el = <Select style={{width:'130px'}} value={self.state.data[item.key]} name={item.key} options={self.townshipSelect()} onChange={self.onChange} />
      }
      return <div key={index} className='form-group'>
        <div style={{display:'block', width:item.width}}>
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
      <button onClick={this.clearFields} type='button' style={{marginTop:'20px', marginLeft:'10px'}} className='btn btn-danger'>Clear</button>
    </form>
  }
})

export default Search
