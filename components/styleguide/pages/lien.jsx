var accounting = require('accounting')
const Lien = React.createClass({
  displayName: 'Lien',
  getInitialState: function() {
    var lien = BackboneApp.Models.Lien.findOrCreate({id:this.props.routeParams.id})
    lien.fetch()
    return {lien: lien}
  },

  render: function()  {
    return <LienHelper {...this.props} lien={this.state.lien} receipts={this.state.lien.get('receipts')} subsequents={this.state.lien.get('subsequents')}/>
  }
})


const LienHelper = React.createBackboneClass({
  mixins: [
      React.BackboneMixin("lien"),
      React.BackboneMixin("receipts", 'change'),
      React.BackboneMixin("subsequents", 'change')
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
  openNoteCreate: function() {
    var self = this
    var CreateNote = Styleguide.Organisms.Lien.CreateNote
    this.setState({
      open: true,
      modal: <CreateNote {...this.props} callback={function(){self.setState({open:false})}} />
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
                <MUI.FlatButton label="Add note" secondary={true} onTouchTap={this.openNoteCreate}/>
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
          <div className='col-md-6'>
            <LienCash lien={lien} onChange={this.onChange}/>
          </div>
        </div>
        <div className='row'>
          <div className='col-md-6'>
            <LienSubs lien={lien} subsequents={lien.get('subsequents')} onChange={this.onChange}/>
          </div>
          <div className='col-md-6'>
            <LienNotes lien={lien} onChange={this.onChange}/>
          </div>
        </div>
        <div className='row'>
          <div className='col-md-12'>
            <LienReceipts lien={lien} receipts={lien.get('receipts')} onChange={this.onChange}/>
          </div>
        </div>
        <div className='row'>
          <div className='col-md-6'>
            <LienLlcs lien={lien} llcs={lien.get('llcs')} onChange={this.onChange}/>
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
        {label: "SALE DATE", key:"sale_date", editable:false},
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

const LienCash = React.createBackboneClass({
  displayName: 'LienCash',

  render: function() {
    var lien = this.props.lien
    var notes = lien.get('annotations')

    var general_fields = [
      [
        {label: "WINNING RATE", key:"winning_bid", editable:true},
        {label: "RECORDING FEE", key:"recording_fee", editable:true, type:'money'},
        {label: "SEARCH FEE", type:'money', key:"search_fee", is_function:true, editable:true},
        {label: "YEAR END PENALTY", key:"2013_yep", editable:true, type:'money'},
        {label: "FACE VALUE", key:"cert_fv", editable:false, type:'money'}
      ],
      [
        {label: "PREMIUM", key:"premium", editable:false, type:'money'},
        {label: "PRINCIPAL BALANCE", key:"principal_balance", is_function:true, type:'money'},
        {label: "TOTAL PAID", key:"total_paid", editable:false, type:'money'},
        {label: "FLAT RATE", key:"flat_rate", is_function:true, type:'money'},
        {label: "CERT INT", key:"cert_interest", is_function:true, type:'money'}
      ],
      [
        {label: "TOTAL CASH OUT", key:"total_cash_out", is_function:true, type:'money'},
        {label: "TOTAL INT DUE", key:"total_interest_due", is_function:true, type:'money'},
        {label: "REDEMPTION AMT", key:"redemption_amount", editable:true, type:'money'},
        {label: "EXPECTED AMT", key:"expected_amount", is_function:true, type:'money'},
        {label: "DIFFERENCE", key:"diff", is_function:true, type:'money'}
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
      } else if(item.type == 'money') {
        val = accounting.formatMoney(val/100, {symbol : "$", decimal : ".", precision : 2, format: "%s%v"})
        if (item.editable){
          edit = <span style={{display:'inline-block', minWidth:'100px', paddingRight:'10px'}}>
            <PlainEditable style={{backgroundColor:'red'}} onBlur={self.props.onChange(item)} value={val} />
          </span>
        } else {
          edit = <span style={{paddingRight:'15px'}}> {val}</span>
        }
      } else if(item.type =='number') {
        val = accounting.toFixed(val, 2)
        if(item.editable) {
          edit = <span style={{display:'inline-block', minWidth:'100px', paddingRight:'10px'}}>
              <PlainEditable onBlur={self.props.onChange(item)} value={val.toString()} />
            </span>
        } else {
          edit = <span style={{paddingRight:'15px'}}>{val.toString()}</span>
        }
      } else {
        if(item.editable) {
          edit = <span style={{display:'inline-block', minWidth:'100px', paddingRight:'10px'}}>
            <PlainEditable onBlur={self.props.onChange(item)} value={val.toString()} />
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
        if(field.is_function) {
          val = self.props.lien[field.key]()
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

const LienSubs = React.createBackboneClass({
  displayName: 'LienSubs',
  mixins: [
      // React.BackboneMixin("lien")
      React.BackboneMixin("subsequents", 'change')
  ],
  onSubState: function(){},
  rowGetter: function(i) {
    var sub = this.props.lien.get('subsequents').models[i]
    var acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
    var amount = sub.amount() || 0
    return {
      type: sub.get('sub_type'),
      date: moment(sub.get('sub_date')).format('MM/DD/YY'),
      amt: accounting.formatMoney(amount/100, acc_format) ,
      int: accounting.formatMoney(sub.interest()/100, acc_format) ,
      number: "",
      actions: {subsequent:sub}
    }
  },
  render: function() {
    var lien = this.props.lien

    var columns = [
      {name:"TYPE", key:'type'},
      {name:"Sub date", key:'date'},
      {name:"Check #", key:'number'},
      {name:"Date paid", key:'date'},
      {name:"Amount", key:'amt'},
      {name:"Interest", key:'int'},
      {name:"Actions", key:'actions', formatter : Formatter}
    ]

    var sub_table = <ReactDataGrid
      columns={columns}
      enableCellSelect= {true}
      rowGetter={this.rowGetter}
      rowsCount={lien.get('subsequents').models.length}
      minHeight={130}
    />

    return <div className='panel panel-default'>
      <div className='panel-heading'>
        <h3 className='panel-title'>
          <span>Subsequents</span>
        </h3>
        <div style={{width:'100%'}}>
          {sub_table}
        </div>
      </div>
    </div>
  }
})
const Formatter = React.createBackboneClass({
  displayName: 'formatter',
  mixins: [
    React.BackboneMixin({
      modelOrCollection: function(props) {
          return props.value.subsequent;
      }
    })
  ],

  toggle_void: function() {
    var sub = this.props.value.subsequent
    sub.set('void', !sub.get('void'))
    sub.save()
  },
  render: function() {
    var void_state = 'clear'
    var iconStyles = {
      color: '#FB8C00',
      marginRight: 10
    };
    if(this.props.value.subsequent.get('void')) {
      void_state = 'add'
    }
    return <div>
      <MUI.Libs.FontIcons onClick={this.toggle_void} className="muidocs-icon-action-home material-icons orange600" style={iconStyles}>
        {void_state}
      </MUI.Libs.FontIcons>
    </div>
  }
})

const LienNotes = React.createClass({
  displayName: 'LienNotes',

  render: function() {
    var lien = this.props.lien
    var notes = []//lien.get('annotations')
    var note_html = notes.map(function(note, key) {
      return <div key={key}>BLLAH</div>
    })

    return <div className='panel panel-default'>
      <div className='panel-heading'>
        <h3 className='panel-title'>Notes</h3>
        <ul className='list-group' style={{height:'130px'}}>
          {note_html}
        </ul>
      </div>
    </div>
  }
})

const LienLlcs = React.createBackboneClass({
  displayName: 'LienLLCs',
  mixins: [
    React.BackboneMixin('llcs', 'change')
  ],
  rowGetter: function(i) {
    var llc = this.props.lien.get('llcs').models[i]
    if( !llc) {
      return {
        llc: 'No owner',
        start: moment(new Date()).format('MM/DD/YYYY'),
        end: ""
      }
    }
    var row = {
      llc: llc.get('name'),
      start: moment(llc.get('start_date')).format('MM/DD/YYYY'),
      end: ""
    }
    if( llc.get('end_date')) {
      row.end = moment(llc.get('end_date')).format('MM/DD/YYYY')
    }
    return row
  },
  render: function() {
    var lien = this.props.lien
    var columns = [
      {name:"LLC", key:'llc'},
      {name:"Start date", key:'start'},
      {name:"End date", key:'end'}
    ]

    var llc_table = <ReactDataGrid
      columns={columns}
      enableCellSelect={true}
      rowGetter={this.rowGetter}
      rowsCount={lien.get('llcs').length}
      minHeight={130}
    />

    return <div className='panel panel-default'>
      <div className='panel-heading'>
        <h3 className='panel-title'>
          <span>Owners</span>
        </h3>
        <div style={{width:'100%'}}>
          {llc_table}
        </div>
      </div>
    </div>
  }
})

const LienReceiptActions = React.createBackboneClass({
  displayName: 'LienCheckActions',
  mixins: [
    React.BackboneMixin('receipt', 'change')
  ],
  toggle_void: function() {
    var receipt = this.props.value.receipt
    receipt.set('void', !receipt.get('void'))
    receipt.save()
  },
  render: function() {
    var iconStyles = {
      color: '#FB8C00',
      marginRight: 10,
    }
    var void_state = 'clear'
    if(this.props.value.receipt.get('void')) {
      void_state = 'add'
    }

    return <div>
      <MUI.Libs.FontIcons onClick={this.props.value.onClick} className="muidocs-icon-action-home material-icons orange600" style={iconStyles}>edit</MUI.Libs.FontIcons>
      <MUI.Libs.FontIcons onClick={this.toggle_void} className="muidocs-icon-action-home material-icons orange600" style={iconStyles}>{void_state}</MUI.Libs.FontIcons>
    </div>
  }
})


const LienReceipts = React.createBackboneClass({
  displayName: 'LienReceipts',

  mixins: [
    React.BackboneMixin('receipts', 'change')
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

  openEdit: function(receipt) {
    var self = this
    var EditReceipt = Styleguide.Organisms.Lien.EditReceipt
    this.setState({
      open: true,
      modal: <EditReceipt {...this.props} receipt={receipt} callback={function(){self.setState({open:false})}}/>
    })
  },
  openCreate: function() {
    var self = this
    var CreateReceipt = Styleguide.Organisms.Lien.CreateReceipt
    this.setState({
      open: true,
      modal: <CreateReceipt {...this.props} callback={function(){self.setState({open:false})}} />,
      modal_actions: [<MUI.FlatButton label="Create" secondary={true} onTouchTap={this.handleClose} />]
    })
  },

  getDialog: function() {
    var modal = this.state.modal
    var Dialog = MUI.Libs.Dialog

    return <Dialog open={this.state.open} actions={this.state.modal_actions} onRequestClose={this.handleClose} contentStyle={{width:'500px'}}>
      {modal}
    </Dialog>
  },

  rowGetter: function(i){
    var receipt = this.props.lien.get('receipts').models[i]
    var redeem_date = ""
    if(receipt.get('redeem_date')){
      redeem_date = moment(receipt.get('redeem_date')).format('MM/DD/YYYY')
    }
    var acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
    return {
      deposit_date: moment(receipt.get('deposit_date')).format('MM/DD/YYYY')
      ,account: "NA"
      ,check_date: moment(receipt.get('check_date')).format('MM/DD/YYYY')
      ,check_number: receipt.get('check_number')
      ,redeem_date: redeem_date
      ,check_amount: accounting.formatMoney(receipt.amount()/100, acc_format)
      ,principal: receipt.get('check_principal')
      ,subs: receipt.get('check_interest')
      ,code: receipt.get('receipt_type')
      ,expected_amt: accounting.formatMoney(receipt.expected_amount()/100, acc_format)
      ,dif: accounting.formatMoney((receipt.expected_amount() - receipt.amount())/100, acc_format)
      ,actions: {onClick:this.openEdit.bind(this, receipt), receipt:receipt}
    }
  },

  getColumns: function(){
    return [
      {name:"Deposit date", key:'deposit_date'}
      ,{name:"Redeem date", key:'redeem_date'}
      ,{name:"Account", key:'account'}
      ,{name:"Check date", key:'check_date'}
      ,{name:"Check #", key:'check_number'}
      ,{name:"Code", key:'code'}
      ,{name:"Check amount", key:'check_amount'}
      ,{name:"Expected Amt", key:'expected_amt'}
      ,{name:"Dif", key:'dif'}
      ,{name:"Actions", key:'actions', formatter: LienReceiptActions}
    ]
  },

  render: function() {
    var lien = this.props.lien

    var receipt_table = <ReactDataGrid
      columns={this.getColumns()}
      enableCellSelect={true}
      rowGetter={this.rowGetter}
      rowsCount={lien.get('receipts').models.length}
      minHeight={130}
    />

    return <div className='panel panel-default'>
      <div className='panel-heading'>
        {this.getDialog()}
        <div style={{width:'100%'}}>
          {receipt_table}
        </div>
      </div>
    </div>
  }
})


export default Lien
