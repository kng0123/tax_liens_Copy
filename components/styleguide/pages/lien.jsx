var accounting = require('accounting')
const Lien = React.createClass({
  displayName: 'Lien',
  getInitialState: function() {
    var lien = BackboneApp.Models.Lien.findOrCreate({id:this.props.routeParams.id})
    lien.fetch()
    return {lien: lien}
  },

  render: function()  {
    return <LienHelper {...this.props} lien={this.state.lien} />
  }
})


const LienHelper = React.createBackboneClass({
  mixins: [
      React.BackboneMixin("lien")
  ],
  getInitialState: function() {
    return {
      open: false,
      modal: undefined,
      modal_actions: <div></div>
    }
  },

  handleClose: function() {
    this.setState({ open: false})
  },

  openCreate: function() {
    var self = this
    var CreateReceipt = Styleguide.Organisms.Lien.CreateReceipt
    this.setState({
      open: true,
      modal: <CreateReceipt {...this.props} callback={function(){self.setState({open:false})}} />
    })
  },
  openSubCreate: function() {
    var self = this
    var CreateSub = Styleguide.Organisms.Lien.CreateSub
    this.setState({
      open: true,
      modal: <CreateSub {...this.props} callback={function(){self.setState({open:false})}} />
    })
  },

  getDialog: function() {
    var modal = this.state.modal
    var Dialog = MUI.Libs.Dialog

    return <Dialog open={this.state.open} actions={this.state.modal_actions} onRequestClose={this.handleClose} contentStyle={{width:'500px'}}>
      {modal}
    </Dialog>
  },

  onChange: function(item) {
    var self = this
    return function(data) {
      var val
      if(item.type == 'date') {
        val = moment(data.target.value).toDate()
      } else if (item.type == 'bool') {
        val = $(data.target).is(':checked')
      }else if (item.type == 'select') {
        val = data.value
      }else if (item.type == 'money') {
        val = Math.round(accounting.unformat($(data.target).html()) * 100)
      } else {
        val = arguments[1]
      }
      var lien = self.props.lien
      var old = lien.get(item.key)
      if( typeof(old) == 'number') {
        val = parseFloat(val)
      }

      lien.set(item.key, val)
      self.setState({lien:lien})
      self.save()
    }
  },

  save: function() {
    this.props.lien.save()
  },

  render: function() {
    var RaisedButton = MUI.RaisedButton
    var lien = this.props.lien
    if(!lien) {
      return <div></div>
    }
    if(!lien.get('lien_type')) {
      return <div></div>
    }
    var state_options = [
        { value: 'redeemed', label: 'Redeemed' },
        { value: 'bankruptcy', label: 'Bankruptcy' },
        { value: 'foreclosure', label: 'Foreclosure' },
        { value: 'own', label: 'Own Home' },
        { value: 'none', label: 'No Subs' },
    ];

    return <div>
      {this.getDialog()}
      <div className='container'>
        <div className='row'>
          <div style={{width:'1200px', margin:'0 auto'}}>
            <Styleguide.Organisms.Lien.Search {...this.props} />
          </div>
        </div>
      </div>
      <div className='container'>
        <div className='row'>
          <div className='col-lg-12'>
            <div className='container-fluid'>
              <h5>
                <span>{"LIEN #"+this.props.lien.get('id')}</span>
                <MUI.FlatButton label="Add receipt" secondary={true} onTouchTap={this.openCreate}/>
                <MUI.FlatButton label="Add sub" secondary={true} onTouchTap={this.openSubCreate}/>
                <span style={{width:'150px', display:'inline-block'}}>
                  <Select name={'status'} value={lien.get('status')} options={state_options} onChange={this.onChange({type:'select', key:"status"})} />
                </span>
              </h5>
            </div>
          </div>
        </div>
        <div className='row'>
          <div className='col-md-6'>
            <LienInfo lien={lien} onChange={this.onChange}/>
          </div>
        </div>
      </div>
    </div>
  }
})

const LienInfo = React.createBackboneClass({
  displayName: 'LienInfo',

  render: function() {
    var lien = this.props.lien
    var notes = lien.get('annotations')

    var general_fields = [
      [{label: "Lien ID", key:"id", id:true},
      {label: "BLOCK/LOT/QUAL", key:"block_lot"},
      {label: "TOWNSHIP", key:"county", editable:false},
      {label: "CERTIFICATE #", key:"cert_number", editable:true},
      {label: "MUA ACCOUNT #", key:"mua_account_number", editable:true}
    ],

      [{label: "ADDRESS", key:"address", editable:true},
      {label: "CITY", key:"city", editable:true},
      {label: "STATE", key:"state", editable:true},
      {label: "ZIP", key:"zip", editable:true},
      {label: "REDEEM IN 10?", key:"redeem_in_10", editable:true, type:'bool'}
    ],

      [
        {label: "SALE DATE", key:"sale_date", editable:true, type:'date'},
        {label: "RECORDING DATE", key:"recording_date", editable:true, type:'date'},
        {label: "REDEMPTION DATE", key:"redemption_date", editable:true, type:'date'}

      ]
    ]

    var editable = PlainEditable
    var date_picker = DatePicker
    var checkbox = MUI.Checkbox
    var gen_editable = function(key, item, val) {
      let edit = undefined;
      if(item.type == 'date') {
        edit = <div style={{display: 'block', position: 'relative', width: '100px'}}>
          <Styleguide.Molecules.Forms.DatePicker style={{width:'150px'}} name='redeem_date' value={val} onChange={self.props.onChange(item)} />
        </div>
      } else if(item.type =='bool') {
        edit = <MUI.Checkbox onCheck={self.props.onChange(item)} checked={!!val} />
      } else if(item.type =='number') {
        val = accounting.toFixed(val, 2)
        if(item.editable) {
          edit = <span style={{display:'inline-block', minWidth:'100px', paddingRight:'10px'}}>
              <PlainEditable onBlur={self.props.onChange(item)} value={val} />
            </span>
        } else {
          edit = <span style={{paddingRight:'15px'}}>{val}</span>
        }
      } else {
        if(item.editable) {
          edit = <span style={{display:'inline-block', minWidth:'100px', paddingRight:'10px'}}>
            <PlainEditable onBlur={self.props.onChange(item)} value={val} />
          </span>
        } else {
          edit = <small className='text-muted'>{val || "Empty"}</small>
        }
      }

      return <fieldset style={{marginBottom:'0px'}} className='form-group' key={key}>
        <div>
          <label style={{marginBottom:'0px'}}>{item.label}</label>
        </div>
        {edit}
      </fieldset>
    }

    var self = this
    var gen_html = general_fields.map( function(fields,k) {
      var field_html = fields.map( function(field, field_key){
        let val = self.props.lien.get(field.key)
        if (field.id) {
          val = self.props.lien.get('id')
        }
        if(val == undefined && field.type != 'bool') {
          val = "Empty"
        }
        return gen_editable(field_key, field, val)
      })

      return <div className='col-lg-4' key={k}>
        {field_html}
      </div>
    })
    return <div className='panel panel-default'>
      <div className='panel-heading'>
        <Formsy.Form className='container-fluid'>
          <div className='row'>
            {gen_html}
          </div>
        </Formsy.Form>
      </div>
    </div>
  }
})

export default Lien
