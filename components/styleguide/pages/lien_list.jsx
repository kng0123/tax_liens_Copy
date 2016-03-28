var PlainEditable = require('react-plain-editable');
const LienList = React.createClass({
  displayName: 'LienList',
  getInitialState: function() {
    return {liens: new BackboneApp.Collections.LienCollection()}
  },

  render: function()  {
    return <LienListHelper {...this.props} liens={this.state.liens} />
  }
})

var LienListHelper = React.createClass({
  displayName: 'LienListHelper',
  mixins: [
      React.BackboneMixin("liens")
  ],
  contextTypes: {
    router: React.PropTypes.object
  },
  getInitialState: function() {
    return {
      open: false,
      modal: undefined
    }
  },

  handleClose: function() {
    this.setState({ open: false})
  },
  getDialog: function() {
    var modal = this.state.modal
    var Dialog = MUI.Libs.Dialog

    return <Dialog open={this.state.open} actions={this.state.modal_actions} onRequestClose={this.handleClose} contentStyle={{width:'500px'}}>
      {modal}
    </Dialog>
  },
  exportReceipts: function() {
    var self = this
    var ExportReceipts = Styleguide.Organisms.Lien.ExportReceipts
    this.setState({
      open: true,
      modal: <ExportReceipts {...this.props} liens={this.state.liens} callback={function(){self.setState({open:false})}} />
    })
  },
  exportLiens: function() {
    var self = this
    var ExportLiens = Styleguide.Organisms.Lien.ExportLiens
    this.setState({
      open: true,
      modal: <ExportLiens {...this.props} liens={this.state.liens} callback={function(){self.setState({open:false})}} />
    })
  },

  componentWillMount: function() {
    this.queryLiens(this.props)
  },

  componentWillReceiveProps: function(props) {
    this.queryLiens(props)
  },

  queryLiens: function(props){
    var query_params = props.search
    props.liens.fetch({data: query_params})
  },

  goToLien: function(indices) {
    var lien = this.props.liens.models[indices[0]]
    this.context.router.push('/lien/item/'+lien.get('id'))
  },


  render: function() {
    var RaisedButton = MUI.RaisedButton
    var self = this

    var sub_headers = ["ID", "TOWNSHIP", "BLOCK", "LOT", "QUALIFIER", "MUA ACCT 1", "CERTIFICATE #", "ADDRESS", "SALE DATE"]
    var editable = PlainEditable
    var sub_rows = this.props.liens.models.map(function(lien, k) {
      var mua_account_number
      if (lien.get('mua_accounts').models.length) {
        mua_account_number = lien.get('mua_accounts').models[0].get('account_number')
      }
      return [
        lien.get('id'),
        <div onClick={self.goToLien} data-id={lien.get('id')}>{ lien.get('county')}</div>,
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        mua_account_number,
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).format('MM/DD/YYYY')
      ]
    })

    var widths = ['40px', '20px','20px','30px','50px','50px','50px','50px','50px','50px']

    var sub_table = React.Factory.table({ widths:widths, selectable:true, headers: sub_headers, rows: sub_rows, onRowSelection:this.goToLien})

    return <div>
      {this.getDialog()}
      <div className='container'>
        <div className='row'>
          <div style={{width:'1200px', margin:'0 auto'}}>
            <Styleguide.Organisms.Lien.Search {...this.props} />
          </div>
        </div>
      </div>
      <div className='container-fluid'>
        <div className='row'>
          <div className='col-lg-12'>
            <MUI.FlatButton label="Export receipts" secondary={true} onTouchTap={this.exportReceipts}/>
            <MUI.FlatButton label="Export liens" secondary={true} onTouchTap={this.exportLiens}/>
          </div>
        </div>
        <div className='row'>
          <div className='col-lg-12'>
            {sub_table}
          </div>
        </div>
      </div>
    </div>
  }
})

export default LienList
