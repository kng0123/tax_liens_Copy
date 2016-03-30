var Paper = require('material-ui/lib/paper');
const ProcessSubs = React.createClass( {
  displayName: 'LienProcessSubsFormHelper',

  getInitialState: function() {
    var ts = new BackboneApp.Collections.TownshipCollection()
    ts.fetch()
    var batches = new BackboneApp.Collections.SubsequentBatchCollection()
    batches.fetch()

    return {
      batches: batches,
      townships: ts
    }
  },
  render: function() {
    return <ProcessSubsHelper {...this.props} {...this.state} />
  }
})
const ProcessSubsHelper = React.createClass( {
  displayName: 'LienProcessSubsFormHelper',

  contextTypes: {
    router: React.PropTypes.object
  },

  mixins: [
    React.BackboneMixin('batches'),
    React.BackboneMixin('townships')
  ],

  getInitialState: function() {
    return {
      error: "",
      data: {
        township: undefined
      },
      batch_date: new Date()
    }
  },
  onChange: function(event) {
    this.setState({data:{township:event.value}})
    this.props.batches.fetch({data:{township: event.value}})
  },

  goToBatch: function(indices){
    var batch = this.props.batches.models[indices[0]]
    this.context.router.push('/app/lien/batch/'+batch.id)
  },

  updateBatchDate: function(event) {
    this.setState({batch_date: new Date(event.target.value)})
  },

  valueRenderer: function(val){
    if( val ) {
      return <span>{val.label}</span>
    }
  },

  createBatch: function(event) {
    // TODO
    var batch = {
      sub_date: this.state.batch_date,
      township: this.state.data.township,
    }
    //TODO: Create sub
    var new_batch = new BackboneApp.Models.SubsequentBatch({data:batch})
    var resp=new_batch.save()
    var self = this
    resp.success(function(batch) {
      self.context.router.push('/app/lien/batch/'+batch.id)
    })
    self.setState({error:undefined})
    resp.fail(function(obj, code, message) {
      if(obj.status == 400) {
        self.setState({
          error: <div class="alert alert-danger">
            <strong>Error!</strong>
            <span>No active liens found for {batch.township}</span>
            <br />
            <span>Must have at least 1 lien where status is not redeemed or none</span>
          </div>
        })
      }
    })
    //
  },

  townships: function() {
    return this.props.townships.models.map(function(township){
      return {label: township.get('name'), value:township.get('name')}
    })
  },

  render: function() {
    var TextField = MUI.TextField
    var RaisedButton = MUI.RaisedButton
    var paperStyle=  {
      width: 450,
      margin: '20px auto',
      padding: 20
    }
    //select = React.createFactory Select
    // editable = React.createFactory PlainEditable
    // date_picker = React.createFactory DatePicker
    // f = React.createFactory Formsy.Form
    // dp = React.createFactory Styleguide.Molecules.Forms.DatePicker
    var batch_headers = ["TOWNSHIP", "DATE"]

    var batch_rows = this.props.batches.models.map(function(batch, k) {
      return [
        batch.get('township').get('name'),
        moment(batch.get('sub_date')).format('MM/DD/YYYY')
      ]
    })

    var batch_table = React.Factory.table({selectable:true, onRowSelection:this.goToBatch, headers: batch_headers, rows: batch_rows})
    var val = ""
    if( this.state.data.township){
      val = this.state.data.township
    }

    return <div className='container'>
      {this.state.error}
      <div className='row'>
        <div className='col-md-offset-4 col-md-4'>
          <h3 className='strong text-center text-grey'>Specify sub list</h3>
          <div style={paperStyle}>
            <form>
              <Select name='township' style={{width:'360px'}} value={val} options={this.townships()} onChange={this.onChange} valueRenderer={this.valueRenderer} />
            </form>
          </div>
        </div>
      </div>
      <div className='row'>
        <div className='col-sm-12'>
          <p>Recent Subsequents</p>
          <Formsy.Form className='form-inline' onValidSubmit={this.createBatch}>
            <div className='form-group'>
              <div style={{float:'left', width:'160px'}}>
                <div style={{display: 'block', position: 'relative', width: '100px'}}>
                  <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='redeem_date' value={moment(this.state.batch_date)} required  onChange={this.updateBatchDate} />
                </div>
              </div>
              <div style={{float:'left'}}>
                <Select name='township' style={{width:'200px'}} value={val} options={this.townships()} onChange={this.onChange} valueRenderer={this.valueRenderer} />
              </div>
              <RaisedButton label="Create new batch" onClick={this.logout} type='submit' disabled={!(val && this.state.batch_date)} primary={true} />
            </div>
          </Formsy.Form>
        </div>
        <div className='col-sm-12'>
          {batch_table    }
        </div>
      </div>
    </div>
  }
})

export default ProcessSubs
