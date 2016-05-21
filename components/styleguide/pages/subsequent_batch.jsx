var Paper = require('material-ui/lib/paper');
var accounting = require('accounting')
const SubsequentBatch = React.createClass( {
  displayName: 'SubsequentBatch',
  contextTypes: {
    router: React.PropTypes.object
  },
  getInitialState: function() {
    var subs = BackboneApp.Models.SubsequentBatch
    var batch = subs.findOrCreate({id:parseInt(this.props.params.id)})
    batch.fetch()

    return {
      batch: batch
    }
  },
  render: function() {
    return <SubsequentBatchHelper {...this.props} {...this.state} />
  }
})
const SubsequentBatchHelper = React.createClass( {
  displayName: 'SubsequentBatchHelper',
  contextTypes: {
    router: React.PropTypes.object
  },
  getInitialState: function() {
    return {
      add_columns:0
    }
  },
  mixins: [
    React.BackboneMixin('batch', 'change add remove')
  ],

  addColumn: function() {
    this.setState({add_columns:this.state.add_columns+1})
  },

  onChange: function(lien, type, sub){
    var self = this
    return function(event) {
      var val = $(event.target).text() || 0
      val = Math.round(accounting.unformat(val) * 100)

      if(sub.get('lien')) {
        sub.set('amount', parseFloat(val))
        sub.save()
      } else {
        var data = {
          type: type,
          sub_date: self.props.batch.get('sub_date').toString(),
          amount: $(event.target).text(),
          lien_id: lien.get('id'),
          subsequent_batch_id: self.props.batch.get('id')
        }
        //TODO: Create sub
        var new_sub = new BackboneApp.Models.Subsequent(data)
        new_sub.save()
      }
    }
  },

  exportXLSX: function() {
    window.location.assign("/subsequent_batch/"+this.props.batch.get('id')+".xlsx");
    // this.window.location =
  },

  goToLien: function(event) {
    var id = event.target.dataset.id
    this.context.router.push('/app/lien/item/'+id)
  },

  toggleVoid: function() {
    var batch = this.props.batch

    var void_state = !!batch.get('void')
    batch.set('void', !void_state)
    batch.save()
  },

  subDate: function(lien, date, type) {
    var matches = lien.get('subs').map(function(sub) {
      if( sub.get('type') == type){
        if( date.format('MM/DD/YYYY') == moment(sub.get('sub_date')).format('MM/DD/YYYY')) {
          return sub
        }
      }
    }).filter(function(sub){
      return sub
    })
    if( matches.length && matches[0].get('amount')) {
      return matches[0]
    }
  },

  render: function() {
    if( !this.props.batch) {
      return <div>Loading...</div>
    }
    var RaisedButton = MUI.RaisedButton
    var sub_headers = ["TOWNSHIP", "BLOCK", "LOT", "QUALIFIER", "MUA ACCT 1", "CERTIFICATE #", "ADDRESS", "SALE DATE", "TAX", "UTILITY", "OTHER"]

    //Count number of misc subs
    var num_misc = 0
    var self = this;
    this.props.batch.get('liens').map(function(lien, k) {
      var subs = []
      if( lien.get('subsequents')) {
        subs = lien.get('subsequents').models
      }
      let misc_count_local = 0
      subs.map(function(sub){
        if( sub && sub.get('sub_date') ==  self.props.batch.get('sub_date')) {
          var sub_date = sub.get('sub_date')
          if(sub.get('sub_type') == 'misc') {
            misc_count_local++
          }
        }
      })
      if ( misc_count_local > num_misc ) {
        num_misc = misc_count_local
      }
    })
    num_misc = num_misc + this.state.add_columns
    sub_headers = sub_headers.concat(Array.apply(null, Array(num_misc)).map(function () {
      return 'MISC';
    }))
    // editable = React.createFactory PlainEditable
    var self = this
    var sub_rows = this.props.batch.get('liens').map(function(lien, k) {
      var date = moment(self.props.date)
      var sub_date = ""
      var subs = []

      if( lien.get('subsequents')) {
        subs = lien.get('subsequents').models.map(function(sub){
          return sub
        })
      }
      var misc_count = 0
      subs = subs.reduce(function(m, sub){
        if( sub && sub.get('sub_date') ==  self.props.batch.get('sub_date')) {
          var sub_date = sub.get('sub_date')
          if(sub.get('sub_type') == 'misc') {
            m[misc_count++] = sub
          } else {
            m[sub.get('sub_type')] = sub
          }
        }
        return m
      }, {})
      var tax_sub = subs['tax'] || new BackboneApp.Models.Subsequent({sub_type:'tax', sub_date:sub_date})
      var utility_sub = subs['utility'] || new BackboneApp.Models.Subsequent({sub_type:'utility', sub_date:sub_date})
      var other_sub = subs['other'] || new BackboneApp.Models.Subsequent({sub_type:'other', sub_date:sub_date})
      var acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
      var tax_amount = accounting.formatMoney(tax_sub.get('amount')/100, acc_format)
      var util_amount = accounting.formatMoney(utility_sub.get('amount')/100, acc_format)
      var other_amount = accounting.formatMoney(other_sub.get('amount')/100, acc_format)

      var base = [
        <div onClick={self.goToLien} data-id={lien.get('id')}>{lien.get('county')}</div>,
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).format('MM/DD/YYYY'),
        <div style={{border:'1px solid black'}}>
          <PlainEditable onBlur={self.onChange(lien, 'tax', tax_sub)} value={(tax_sub.get('amount')) ? tax_amount : undefined } />
        </div>,
        <div style={{border:'1px solid black'}}>
          <PlainEditable onBlur={self.onChange(lien, 'utility', utility_sub)} value={((utility_sub.get('amount')) ? util_amount :undefined )} />
        </div>,
        <div style={{border:'1px solid black'}}>
          <PlainEditable onBlur={self.onChange(lien, 'other', other_sub)} value={((other_sub.get('amount')) ? other_amount :undefined )} />
        </div>
      ]
      return base.concat(Array.apply(null, Array(num_misc)).map(function (item, index) {
        let misc_sub = subs[index] || new BackboneApp.Models.Subsequent({sub_type:'misc', sub_date:sub_date})
        let misc_amount = accounting.formatMoney(misc_sub.get('amount')/100, acc_format)
        return <div style={{border:'1px solid black'}}>
          <PlainEditable onBlur={self.onChange(lien, 'misc', misc_sub)} value={((misc_sub.get('amount')) ? misc_amount :undefined )} />
        </div>
      }))
    })

    var widths = ['40px', '20px','20px','30px','50px','50px','50px','50px','50px','50px','50px','50px','50px']
    widths = widths.concat(Array.apply(null, Array(num_misc)).map(function () {
      return '50px';
    }))
    var sub_table = React.Factory.table({ widths:widths, selectable:false, headers: sub_headers, rows: sub_rows})
    var void_label = "Void"

    if(this.props.batch.get('void')) {
      void_label = "Un-Void"
    }
    return <div className='container-fluid'>
      <div className='row'>
        <div className='col-lg-12'>
          <p>Interest for {moment(this.props.batch.get('sub_date')).format('MM/DD/YYYY')}</p>
        </div>
        <div className='col-lg-12'>
          <RaisedButton label="Export Excel" onTouchTap={this.exportXLSX} type='button' primary={true} />
          <RaisedButton label={void_label} onTouchTap={this.toggleVoid} type='button' primary={false} />
          <RaisedButton label="Add column" onTouchTap={this.addColumn} type='button' primary={false} />
          {sub_table}
        </div>
      </div>
    </div>
  }
})

export default SubsequentBatch
