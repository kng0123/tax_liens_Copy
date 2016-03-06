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

  createBatch: (event) ->
    event.stopPropagation()
    event.preventDefault()
    query = new Parse.Query(App.Models.Lien);
    query.include("subs")
    query.equalTo("township", @state.data.township)
    #TODO WHAT DOES THIS MEAN???
    #Principal Balance > $0
    query.notEqualTo('status', 'redeemed')
    query.notEqualTo('status', 'none')
    query.find({
    	success : (liens) =>
        batch = {
          sub_date: @state.batch_date,
          township: @state.data.township,
          subs: [],
          liens: liens
        }
        App.Models.SubBatch.init_from_json(batch).save()
        .then( (batch) =>
          @context.router.push('/lien/batch/'+batch.id)
        )
    	,
    	error : (obj, error) ->
    })


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
        moment(batch.get('sub_date')).format('MM/DD/YYYY')
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
  contextTypes: {
    router: React.PropTypes.object
  },
  getInitialState: ->
    batch: undefined

  componentWillMount: ->
    query = new Parse.Query(App.Models.SubBatch);
    query.equalTo("objectId", this.props.routeParams.id)
    query.include("subs")
    query.include("liens")
    query.find({}).then( (results) =>
      batch = results[0]
      @setState(
        batch: batch
        subs: batch.get('subs').reduce( (m, sub) ->
          m[sub.id] = sub
          return m
        , {})
      )
    )

  onChange: (lien, type, sub) ->
    return (event) =>
      val = $(event.target).text() || 0
      val = Math.round(accounting.unformat(val) * 100)

      if sub.get('lien')
        sub.set('amount', parseFloat(val))
        sub.save()
      else
        data =
          type: type
          sub_date: @state.batch.get('sub_date').toString()
          amount: $(event.target).text()
        sub = App.Models.LienSub.init_from_json(lien, data)

        lien.set('subs', lien.get('subs').concat(sub))
        lien.save().then(() =>
          @state.batch.addSub(sub)
          @state.batch.save()
        ).fail(()->
          debugger
        )


  goToLien: (event) ->
    id = event.target.dataset.id
    @context.router.push('/lien/item/'+id)

  toggleVoid: ->
    batch = @state.batch

    void_state = !!batch.get('void')
    batch.set('void', !void_state)
    batch.get('subs').map( (sub) ->
      sub.set('void', !void_state)
    )
    batch.save().then (batch) =>
      @setState batch:batch

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
    rows = @state.batch.get('liens').map (lien, k) =>
      date = moment(@props.date)
      subs = lien.get('subs').map( (sub) =>
        @state.subs[sub.id]
      )
      subs = subs.reduce( (m, sub) =>
        if sub
          m[sub.get('type')] = sub
        return m
      , {})
      tax_sub = subs['tax']
      utility_sub = subs['utility']
      other_sub = subs['other']
      acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
      tax_amount = accounting.formatMoney(tax_sub.get('amount')/100, acc_format)
      util_amount = accounting.formatMoney(util_sub.get('amount')/100, acc_format)
      other_amount = accounting.formatMoney(other_sub.get('amount')/100, acc_format)
      [
        lien.get('county'),
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).toDate()
        (if tax_sub then tax_amount || "" else "")
        (if utility_sub then util_amount || "" else "")
        (if other_sub then other_amount || "" else "")
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
    if !@state.batch
      return div null, "Loading..."

    RaisedButton = React.createFactory MUI.RaisedButton

    sub_headers = ["TOWNSHIP", "BLOCK", "LOT", "QUALIFIER", "MUA ACCT 1", "CERTIFICATE #", "ADDRESS", "SALE DATE", "TAX", "UTILITY", "OTHER"]
    editable = React.createFactory PlainEditable
    sub_rows = @state.batch.get('liens').map (lien, k) =>
      date = moment(@props.date)
      sub_date = ""
      subs = lien.get('subs').map( (sub) =>
        @state.subs[sub.id]
      )
      subs = subs.reduce( (m, sub) =>
        if sub
          sub_date = sub.get('sub_date')
          m[sub.get('type')] = sub
        return m
      , {})
      tax_sub = subs['tax'] || new App.Models.LienSub({type:'tax', sub_date:sub_date})
      utility_sub = subs['utility'] || new App.Models.LienSub({type:'utility', sub_date:sub_date})
      other_sub = subs['other'] || new App.Models.LienSub({type:'other', sub_date:sub_date})
      acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
      tax_amount = accounting.formatMoney(tax_sub.get('amount')/100, acc_format)
      util_amount = accounting.formatMoney(utility_sub.get('amount')/100, acc_format)
      other_amount = accounting.formatMoney(other_sub.get('amount')/100, acc_format)

      [
        div onClick:@goToLien, 'data-id':lien.get('unique_id'), lien.get('county')
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).format('MM/DD/YYYY')
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'tax', tax_sub), value: if tax_sub.get('amount') then tax_amount
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'utility', utility_sub), value: if utility_sub.get('amount') then util_amount
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'other', other_sub), value: if other_sub.get('amount') then other_amount
      ]

    widths = ['40px', '20px','20px','30px','50px','50px','50px','50px','50px','50px','50px','50px','50px']

    sub_table = Factory.table widths:widths, selectable:false, headers: sub_headers, rows: sub_rows

    void_label = "Void"

    if @state.batch.get('void')
      void_label = "Un-Void"
    div className:'container-fluid',
      div className:'row',
        div className:'col-lg-12',
          p null, "Interest for #{moment(@props.date).format('MM/DD/YYYY')}"
        div className:'col-lg-12',
          RaisedButton label:"Export Excel", onClick:@exportXLSX, type:'button', primary:true
          RaisedButton label:void_label, onClick:@toggleVoid, type:'button', primary:false
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
