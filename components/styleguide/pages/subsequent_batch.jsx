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
    window.location.assign("/subsequent_batch/"+this.props.batch.get('id')+".xls");
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
          <RaisedButton label="Export Excel" onClick={this.exportXLSX} type='button' primary={true} />
          <RaisedButton label={void_label} onClick={this.toggleVoid} type='button' primary={false} />
          <RaisedButton label="Add column" onClick={this.addColumn} type='button' primary={false} />
          {sub_table}
        </div>
      </div>
    </div>
  }
})


// ### original data ###
// ### add worksheet to workbook ###
//
// datenum = (v, date1904) ->
//   if date1904
//     v += 1462
//   epoch = Date.parse(v)
//   (epoch - (new Date(Date.UTC(1899, 11, 30)))) / (24 * 60 * 60 * 1000)
//
// convert_to_xlsx_json = (data, opts) ->
//   `var ws`
//   ws = {}
//   range =
//     s:
//       c: 10000000
//       r: 10000000
//     e:
//       c: 0
//       r: 0
//   R = 0;
//   while R != data.length
//     C = 0
//     while C != data[R].length
//       if range.s.r > R
//         range.s.r = R
//       if range.s.c > C
//         range.s.c = C
//       if range.e.r < R
//         range.e.r = R
//       if range.e.c < C
//         range.e.c = C
//       cell = v: data[R][C]
//       if cell.v == null
//         ++C
//         continue
//       cell_ref = XLSX.utils.encode_cell(
//         c: C
//         r: R)
//       if typeof cell.v == 'number'
//         cell.t = 'n'
//       else if typeof cell.v == 'boolean'
//         cell.t = 'b'
//       else if cell.v instanceof Date
//         cell.t = 'n'
//         cell.z = XLSX.SSF._table[14]
//         cell.v = datenum(cell.v)
//       else
//         cell.t = 's'
//       if R < 3
//         cell.h = cell.v
//         cell.w = cell.v
//         cell.r = "<t>#{cell.v}</t>"
//       ws[cell_ref] = cell
//       ++C
//     ++R
//   if range.s.c < 10000000
//     ws['!ref'] = XLSX.utils.encode_range(range)
//   ws



  // exportXLSX: ->
  //   Workbook = ->
  //     if !(this instanceof Workbook)
  //       return new Workbook
  //     @SheetNames = []
  //     @Sheets = {}
  //     return
  //
  //   wb = new Workbook
  //   ws_name = 'SheetJS'
  //   #TODO DEFINE DATA
  //
  //   data = [
  //     ["SUB REQUEST"]
  //     ["Interest Date: #{moment(@state.batch.get('sub_date')).format('MM/DD/YYYY')}"]
  //     ["Township", "Block", "Lot", "Qualifier", "MUA Acct 1", "Certificate #", "Address", "Sale Date", "Tax Amount", "Utility Amount", "Other Amount"]
  //   ]
  //   rows = @state.batch.get('liens').map (lien, k) =>
  //     date = moment(@props.date)
  //     subs = lien.get('subs').map( (sub) =>
  //       @state.subs[sub.id]
  //     )
  //     subs = subs.reduce( (m, sub) =>
  //       if sub
  //         m[sub.get('type')] = sub
  //       return m
  //     , {})
  //     tax_sub = subs['tax']
  //     utility_sub = subs['utility']
  //     other_sub = subs['other']
  //     acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
  //     tax_amount = accounting.formatMoney(tax_sub.get('amount')/100, acc_format) if tax_sub
  //     util_amount = accounting.formatMoney(utility_sub.get('amount')/100, acc_format) if utility_sub
  //     other_amount = accounting.formatMoney(other_sub.get('amount')/100, acc_format) if other_sub
  //     [
  //       lien.get('county'),
  //       lien.get('block'),
  //       lien.get('lot'),
  //       lien.get('qualifier'),
  //       lien.get('mua_account_number'),
  //       lien.get('cert_number'),
  //       lien.get('address'),
  //       moment(lien.get('sale_date')).toDate()
  //       (if tax_sub then tax_amount || "" else "")
  //       (if utility_sub then util_amount || "" else "")
  //       (if other_sub then other_amount || "" else "")
  //     ]
  //   data= data.concat rows
  //   ws = convert_to_xlsx_json(data)
  //   wb.SheetNames.push ws_name
  //   wb.Sheets[ws_name] = ws
  //
  //   #Add formating to the sheet
  //   cols = [
  //     {"width":"17.140625","customWidth":"1","wpx":120,"wch":16.43,"MDW":7},
  //     {"width":"6","bestFit":"1","customWidth":"1","wpx":42,"wch":5.29,"MDW":7},
  //     {"width":"5.140625","customWidth":"1","wpx":36,"wch":4.43,"MDW":7},
  //     {"width":"7.7109375","bestFit":"1","customWidth":"1","wpx":54,"wch":7,"MDW":7},
  //     {"width":"18.85546875","bestFit":"1","customWidth":"1","wpx":132,"wch":18.14,"MDW":7},
  //     {"width":"10.42578125","bestFit":"1","customWidth":"1","wpx":73,"wch":9.71,"MDW":7},
  //     {"width":"25.28515625","bestFit":"1","customWidth":"1","wpx":177,"wch":24.57,"MDW":7},
  //     {"width":"10.42578125","bestFit":"1","customWidth":"1","wpx":73,"wch":9.71,"MDW":7},
  //     {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7},
  //     {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7},
  //     {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7}
  //   ]
  //   cols = cols.map( (col) =>
  //     arr = []
  //     Object.keys(col).map (key) ->
  //       arr[key] = col[key]
  //     return arr
  //   )
  //   merges = [{"s":{"c":0,"r":0},"e":{"c":10,"r":0}}]
  //   ws['!cols'] = cols
  //   ws['!merges'] = merges
  //   #TODO Styling does not work
  //   styles = [
  //     {"numFmtId":0,"fontId":"0","fillId":0,"borderId":"0","xfId":"0"},
  //     {"numFmtId":0,"fontId":"2","fillId":0,"borderId":"1","xfId":"0","applyFont":"1","applyFill":"1","applyBorder":"1","applyAlignment":"1"},
  //     {"numFmtId":0,"fontId":"3","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
  //     {"numFmtId":0,"fontId":"1","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
  //     {"numFmtId":0,"fontId":"4","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
  //     {"numFmtId":0,"fontId":"5","fillId":0,"borderId":"2","xfId":"0","applyFont":"1","applyBorder":"1"},
  //     {"numFmtId":14,"fontId":"5","fillId":0,"borderId":"2","xfId":"0","applyNumberFormat":"1","applyFont":"1","applyBorder":"1"},
  //     {"numFmtId":0,"fontId":"0","fillId":0,"borderId":"2","xfId":"0","applyBorder":"1"}
  //   ]
  //   styles = cols.map( (col) =>
  //     arr = [undefined]
  //     Object.keys(col).map (key) ->
  //       arr[key] = col[key]
  //     return arr
  //   )
  //   # ws['!ref'] = "A1:K52"
  //   wb.Styles = CellXf: styles
  //   wbout = XLSX.write(wb,
  //     bookType: 'xlsx'
  //     bookSST: true
  //     type: 'binary')
  //
  //   #Sheet to a buffer - s2ab
  //   s2ab = (s) ->
  //     buf = new ArrayBuffer(s.length)
  //     view = new Uint8Array(buf)
  //     i = 0
  //     while i != s.length
  //       view[i] = s.charCodeAt(i) & 0xFF
  //       ++i
  //     buf
  //   saveAs new Blob([ s2ab(wbout) ], type: 'application/octet-stream'), 'test.xlsx'
export default SubsequentBatch
