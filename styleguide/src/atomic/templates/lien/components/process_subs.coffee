Paper = require('material-ui/lib/paper');
Templates.lien_process_subs = React.createClass
  displayName: 'LienProcessSubs'

  setSubs: (e) ->
    e.preventDefault()
    e.stopPropagation()
    township = $("input[name='township']").val()
    date = $("input[name='date']").val()
    data =
      township: township
      date: date
    @props.dispatch(ReduxRouter.pushState(null, @props.location.pathname, data))
    return false

  goBack: ->
    @props.dispatch(ReduxRouter.pushState(null, @props.location.pathname, {}))

  render: ->
    state = @props.location.query
    if state.township and state.date
      React.Factory.lien_process_subs_list date:state.date, township:state.township, goBack:@goBack
    else
      React.Factory.lien_process_subs_form setSubs:@setSubs

Templates.lien_process_subs_form = React.createClass
  displayName: 'LienProcessSubsForm'

  contextTypes: {
    router: React.PropTypes.object
  },

  getInitialState: () ->
    data: {
      township: undefined
    }
    townships: []
    batches: []
    batch_date: new Date()

  componentDidMount: () ->
    township_query = new Parse.Query('Township');
    township_query.find().then( (townships) =>
      @setState townships:townships.map( (township) ->
        label: township.get('township'), value:township
      )
    )
    @fetchBatches()

  fetchBatches: (township) ->
    batch_query = new Parse.Query('SubBatch');
    if township
      batch_query.equalTo('township', township)
    return batch_query.find().then( (batches) =>
      @setState batches:batches
    )

  onChange: (event) ->
    @setState data:{township:event.value}
    @fetchBatches(event.value)

  goToBatch: (indices) ->
    batch = @state.batches[indices[0]]
    @context.router.push('/lien/batch/'+batch.id)

  valueRenderer: (val) ->
    {div, h3, p, form, input, span, ul, li, button} = React.DOM
    if val
      val.get('township')

  render: ->
    {div, h3, p, form, input, span, ul, li, button} = React.DOM
    date_picker = React.createFactory DatePicker
    TextField = React.createFactory MUI.TextField
    RaisedButton = React.createFactory MUI.RaisedButton
    Paper = React.createFactory Paper
    paperStyle=  {
      width: 450,
      margin: '20px auto',
      padding: 20
    }

    select = React.createFactory Select

    Factory = React.Factory

    RaisedButton = React.createFactory MUI.RaisedButton

    batch_headers = ["TOWNSHIP", "DATE"]
    editable = React.createFactory PlainEditable
    batch_rows = @state.batches.map (batch, k) =>
      [
        batch.get('township').get('township')
        moment(batch.get('createdAt')).format('MM/DD/YYYY')
      ]
    # widths = ['40px', '20px','20px','30px','50px','50px','50px','50px','50px','50px','50px','50px','50px']

    batch_table = Factory.table selectable: true, onRowSelection:@goToBatch, headers: batch_headers, rows: batch_rows
    val = ""
    if @state.data.township
      val = @state.data.township
    date_picker = React.createFactory DatePicker
    RaisedButton = React.createFactory MUI.RaisedButton
    div className:'container',
      div className:'row',
        div className:'col-md-offset-4 col-md-4',
          h3 className:'strong text-center text-grey', "Specify sub list"
          div style:paperStyle,
            form
              select name:'township', style:{width:'360px'}, value:val, options:@state.townships, onChange:@onChange, valueRenderer:@valueRenderer
      div className:'row',
        div className:'col-sm-12',
          p null, "Recent Subsequents"
          form className:'form-inline', onSubmit:@createBatch,
            div className:'form-group',
              div style:{float:'left', width:'160px'},
                div style:{display: 'block', position: 'relative', width: '100px'},
                  date_picker className:'form-control datepicker', selected:moment(@state.batch_date), onChange:@updateBatchDate
              div style:{float:'left'},
                select name:'township', style:{width:'200px'}, value:val, options:@state.townships, onChange:@onChange, valueRenderer:@valueRenderer
              RaisedButton label:"Create new batch", onClick:@logout, type:'submit', disabled:!(val.id && @state.batch_date), primary:true
        div className:'col-sm-12',
          batch_table

Templates.lien_process_subs_list = React.createClass
  displayName: 'LienProcessSubsList'

  getInitialState: ->
    liens: []

  componentWillMount: ->
    @queryLiens(@props)

  componentWillReceiveProps: (props)->
    @queryLiens(props)

  queryLiens: (props)->
    query = new Parse.Query(App.Models.Lien);
    query.include("subs")
    query.equalTo("county", @props.township)
    #TODO WHAT DOES THIS MEAN???
    #Principal Balance > $0
    query.notEqualTo('sub_status', 'redeemed')
    query.notEqualTo('sub_status', 'none')
    query.find({
    	success : (results) =>
        @setState liens:results
    	,
    	error : (obj, error) ->
    })

  onChange: (lien, type, sub) ->
    return (event) =>
      val = $(event.target).text()
      if sub
        sub.set('amount', parseFloat(val))
        sub.save()
      else
        data =
          type: type
          sub_date: moment(@props.date).toDate().toString()
          amount: parseFloat(val)
        sub = App.Models.LienSub.init_from_json(lien, data)
        lien.set('subs', lien.get('subs').concat(sub))
        lien.save()

  subDate: (lien, date, type) ->
    matches = lien.get('subs').map (sub) ->
      if sub.get('type') == type
        if date.format('MM/DD/YYYY') == moment(sub.get('sub_date')).format('MM/DD/YYYY')
          return sub
    .filter (sub) ->
      sub
    if matches.length and matches[0].get('amount')
      matches[0]

  exportXLSX: ->
    # Extract data from workbook
    # var workbook = XLSX.read(data, {
    #     type: 'binary',
    #     cellStyles: true //To get groups
    #   });
    # b=workbook.Sheets.Sheet1
    # data = b['!cols'].map(function(col) {
    #   var o = {};
    #   var keys = Object.keys(col)
    #   keys.map(function(k) {
    #     o[k] = col[k];
    #     return o;
    #   })
    #   return o;
    # })
    Workbook = ->
      if !(this instanceof Workbook)
        return new Workbook
      @SheetNames = []
      @Sheets = {}
      return

    wb = new Workbook
    ws_name = 'SheetJS'
    #TODO DEFINE DATA

    data = [
      ["SUB REQUEST"]
      ["Interest Date: #{moment(@props.date).format('MM/DD/YYYY')}"]
      ["Township", "Block", "Lot", "Qualifier", "MUA Acct 1", "Certificate #", "Address", "Sale Date", "Tax Amount", "Utility Amount", "Other Amount"]
    ]
    rows = @state.liens.map (lien, k) =>
      date = moment(@props.date)
      tax_sub = @subDate(lien, date, 'tax')
      utility_sub = @subDate(lien, date, 'utility')
      other_sub = @subDate(lien, date, 'other')
      [
        lien.get('county'),
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).toDate()
        ""
        ""
        ""
      ]
    data= data.concat rows
    ws = convert_to_xlsx_json(data)
    wb.SheetNames.push ws_name
    wb.Sheets[ws_name] = ws

    #Add formating to the sheet
    cols = [
      {"width":"17.140625","customWidth":"1","wpx":120,"wch":16.43,"MDW":7},
      {"width":"6","bestFit":"1","customWidth":"1","wpx":42,"wch":5.29,"MDW":7},
      {"width":"5.140625","customWidth":"1","wpx":36,"wch":4.43,"MDW":7},
      {"width":"7.7109375","bestFit":"1","customWidth":"1","wpx":54,"wch":7,"MDW":7},
      {"width":"18.85546875","bestFit":"1","customWidth":"1","wpx":132,"wch":18.14,"MDW":7},
      {"width":"10.42578125","bestFit":"1","customWidth":"1","wpx":73,"wch":9.71,"MDW":7},
      {"width":"25.28515625","bestFit":"1","customWidth":"1","wpx":177,"wch":24.57,"MDW":7},
      {"width":"10.42578125","bestFit":"1","customWidth":"1","wpx":73,"wch":9.71,"MDW":7},
      {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7},
      {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7},
      {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7}
    ]
    cols = cols.map( (col) =>
      arr = []
      Object.keys(col).map (key) ->
        arr[key] = col[key]
      return arr
    )
    merges = [{"s":{"c":0,"r":0},"e":{"c":10,"r":0}}]
    ws['!cols'] = cols
    ws['!merges'] = merges
    #TODO Styling does not work
    styles = [
      {"numFmtId":0,"fontId":"0","fillId":0,"borderId":"0","xfId":"0"},
      {"numFmtId":0,"fontId":"2","fillId":0,"borderId":"1","xfId":"0","applyFont":"1","applyFill":"1","applyBorder":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"3","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"1","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"4","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"5","fillId":0,"borderId":"2","xfId":"0","applyFont":"1","applyBorder":"1"},
      {"numFmtId":14,"fontId":"5","fillId":0,"borderId":"2","xfId":"0","applyNumberFormat":"1","applyFont":"1","applyBorder":"1"},
      {"numFmtId":0,"fontId":"0","fillId":0,"borderId":"2","xfId":"0","applyBorder":"1"}
    ]
    styles = cols.map( (col) =>
      arr = [undefined]
      Object.keys(col).map (key) ->
        arr[key] = col[key]
      return arr
    )
    # ws['!ref'] = "A1:K52"
    wb.Styles = CellXf: styles
    wbout = XLSX.write(wb,
      bookType: 'xlsx'
      bookSST: true
      type: 'binary')

    #Sheet to a buffer - s2ab
    s2ab = (s) ->
      buf = new ArrayBuffer(s.length)
      view = new Uint8Array(buf)
      i = 0
      while i != s.length
        view[i] = s.charCodeAt(i) & 0xFF
        ++i
      buf
    saveAs new Blob([ s2ab(wbout) ], type: 'application/octet-stream'), 'test.xlsx'
  render: ->
    {div, h3, h1, input, pre,p} = React.DOM
    Factory = React.Factory

    RaisedButton = React.createFactory MUI.RaisedButton

    sub_headers = ["TOWNSHIP", "BLOCK", "LOT", "QUALIFIER", "MUA ACCT 1", "CERTIFICATE #", "ADDRESS", "SALE DATE", "TAX", "UTILITY", "OTHER"]
    editable = React.createFactory PlainEditable
    sub_rows = @state.liens.map (lien, k) =>
      date = moment(@props.date)
      tax_sub = @subDate(lien, date, 'tax')
      utility_sub = @subDate(lien, date, 'utility')
      other_sub = @subDate(lien, date, 'other')

      [
        lien.get('county'),
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).format('MM/DD/YYYY')
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'tax', tax_sub), value: if tax_sub then tax_sub.get('amount').toString()
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'utility', utility_sub), value: if utility_sub then utility_sub.get('amount').toString()
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'other', other_sub), value: if other_sub then other_sub.get('amount').toString()
      ]
    widths = ['40px', '20px','20px','30px','50px','50px','50px','50px','50px','50px','50px','50px','50px']

    sub_table = Factory.table widths:widths, headers: sub_headers, rows: sub_rows

    div className:'container-fluid',
      div className:'row',
        div className:'col-lg-12',
          p null, "Interest for #{moment(@props.date).format('MM/DD/YYYY')}"
        div className:'col-lg-12',
          RaisedButton label:"Go back", onClick:@props.goBack, type:'button', primary:true
          RaisedButton label:"Export Excel", onClick:@exportXLSX, type:'button', primary:true
          sub_table


### original data ###
### add worksheet to workbook ###

datenum = (v, date1904) ->
  if date1904
    v += 1462
  epoch = Date.parse(v)
  (epoch - (new Date(Date.UTC(1899, 11, 30)))) / (24 * 60 * 60 * 1000)

convert_to_xlsx_json = (data, opts) ->
  `var ws`
  ws = {}
  range =
    s:
      c: 10000000
      r: 10000000
    e:
      c: 0
      r: 0
  R = 0;
  while R != data.length
    C = 0
    while C != data[R].length
      if range.s.r > R
        range.s.r = R
      if range.s.c > C
        range.s.c = C
      if range.e.r < R
        range.e.r = R
      if range.e.c < C
        range.e.c = C
      cell = v: data[R][C]
      if cell.v == null
        ++C
        continue
      cell_ref = XLSX.utils.encode_cell(
        c: C
        r: R)
      if typeof cell.v == 'number'
        cell.t = 'n'
      else if typeof cell.v == 'boolean'
        cell.t = 'b'
      else if cell.v instanceof Date
        cell.t = 'n'
        cell.z = XLSX.SSF._table[14]
        cell.v = datenum(cell.v)
      else
        cell.t = 's'
      if R < 3
        cell.h = cell.v
        cell.w = cell.v
        cell.r = "<t>#{cell.v}</t>"
      ws[cell_ref] = cell
      ++C
    ++R
  if range.s.c < 10000000
    ws['!ref'] = XLSX.utils.encode_range(range)
  ws
