Templates.lien_upload = React.createClass
  displayName: 'LienUpload'

  getInitialState: ->
    data: []

  getHeaders: (sheet) ->
    range = XLSX.utils.decode_range(sheet['!ref'])

    cs = range.e.c
    rs = range.e.r

    r = 2 #This is the row the headers are on
    #Group cells by background color into arrays
    group_color_break = null
    groups = []
    group = null
    for c in [0...cs+1] by 1
      cell_key = XLSX.utils.encode_cell(c:c, r:r)
      cell = sheet[cell_key]

      if cell is undefined
        group.push(undefined)
        continue

      #Are we in a different group?
      cellFgColor = if cell.s then cell.s.fgColor else {}
      fg_color = "#{cellFgColor.theme}#{cellFgColor.tint}#{cellFgColor.rgb}"
      if group_color_break != fg_color
        group_color_break = fg_color
        if group
          group.last = last
        group = []
        group.first = cell_key
        group.theme = fg_color
        groups.push(group)
      last = cell_key
      group.push(cell.w)
    groups

  parseObjects: (sheet, groups) ->
    range = XLSX.utils.decode_range(sheet['!ref'])

    cs = range.e.c
    rs = range.e.r

    #skip the first 3 rows
    objects = []
    for row in [3...rs+1] by 1
      object = {general:{}, subs:[], checks:[], season:[]}
      objects.push(object)
      for g in [0..groups.length-1]
        group = groups[g]
        switch group.length
          when 15 then @parseSubs(object, sheet, group, row)
          when 9 then @parseCheck(object, sheet, group, row)
          when 4 then @parseSeason(object, sheet, group, row)
          else @parseGeneral(object, sheet, group, row)
    objects

  parseSubs: (object, sheet, group, row)->
    first = XLSX.utils.decode_cell group.first
    last = XLSX.utils.decode_cell group.last

    tax = sheet[XLSX.utils.encode_cell(c:first.c, r: row)]
    tax_date = sheet[XLSX.utils.encode_cell(c:first.c+1, r: row)]
    util = sheet[XLSX.utils.encode_cell(c:first.c+7, r: row)]
    util_date = sheet[XLSX.utils.encode_cell(c:first.c+8, r: row)]
    total = sheet[XLSX.utils.encode_cell(c:first.c+14, r: row)]
    if tax_date or util_date
      sub =
        tax:  if tax then tax.v
        tax_date: if tax_date then tax_date.v
        util: if util then util.v
        util_date: if util_date then util_date.v
      object.subs.push(sub)


  parseCheck: (object, sheet, group, row)->
    first = XLSX.utils.decode_cell group.first
    last = XLSX.utils.decode_cell group.last
    check_date = sheet[XLSX.utils.encode_cell(c:first.c, r: row)]
    deposit_date = sheet[XLSX.utils.encode_cell(c:first.c+1, r: row)]
    check_number = sheet[XLSX.utils.encode_cell(c:first.c+2, r: row)]
    check_amount = sheet[XLSX.utils.encode_cell(c:first.c+3, r: row)]
    type = sheet[XLSX.utils.encode_cell(c:first.c+4, r: row)]
    dif = sheet[XLSX.utils.encode_cell(c:first.c+5, r: row)]
    check_principal = sheet[XLSX.utils.encode_cell(c:first.c+6, r: row)]
    check_interest = sheet[XLSX.utils.encode_cell(c:first.c+7, r: row)]
    if check_date
      check =
        check_date: if check_date then check_date.v
        deposit_date: if deposit_date then deposit_date.v
        check_number: if check_number then check_number.v
        check_amount: if check_amount then check_amount.v
        type: if type then type.v
        dif: if dif then dif.v
        check_principal: if check_principal then check_principal.v
        check_interest: if check_interest then check_interest.v
      object.checks.push(check)


  parseSeason: ->
    #TODO: I'm not sure what to do with these last fields

  parseGeneral: (object, sheet, group, row)->
    first = XLSX.utils.decode_cell group.first
    last = XLSX.utils.decode_cell group.last
    for i in [first.c..last.c]
      head_cell = XLSX.utils.encode_cell(c:i, r:first.r)
      data_cell = XLSX.utils.encode_cell(c:i, r:row)
      val = if sheet[data_cell]
        sheet[data_cell].v
      else
        ""
      tag_text = sheet[head_cell].v
      tag = switch tag_text
        when "Unique ID" then "unique_id"
        when "County" then "county"
        when "Year" then "year"
        when "LLC" then "llc"
        when "Block/Lot" then "block_lot"
        when "Block" then "block"
        when "Lot" then "lot"
        when "Qualifier" then "qualifier"
        when "Adv #" then "adv_number"
        when "MUA Acct # / Parcel ID" then "mua_account_number"
        when "Cert #" then "cert_number"

        when "Lien Type" then "lien_type"
        when "List Item" then "list_item"
        when "Current Owner" then "current_owner"
        when "Longitude " then "longitude"
        when "Latitude" then "latitude"
        when "Assessed Value" then "assessed_value"
        when "Tax Amount" then "tax_amount"
        when "Status" then "status"
        when "Address" then "address"
        when "Cert FV" then "cert_fv"
        when "Winning Bid" then "winning_bid"
        when "Premium" then "premium"
        when "Total Paid" then "total_paid"
        when "Sale Date" then "sale_date"
        when "Recording Fee" then "recording_fee"
        when "Recording Date" then "recording_date"
        when "Search Fee" then "search_fee"
        when "Flat Rate" then "flat_rate"
        when "Cert Int" then "cert_int"
        else undefined

      if tag
        object.general[tag] = val


  handleFile: (e) ->
    files = e.target.files
    i = undefined
    f = undefined
    i = 0
    f = files[i]
    while i != files.length
      reader = new FileReader
      name = f.name

      reader.onload = (e) =>
        data = e.target.result
        workbook = XLSX.read(data,
          type: 'binary'
          cellStyles: true #To get groups
        )

        sheet = workbook.Sheets["Sheet1"]
        groups = @getHeaders(sheet)
        objects = @parseObjects(sheet, groups)

        @setState(data:objects)

        return

      reader.readAsBinaryString f
      ++i
    return

  handleClick: ->
     fileUploadDom = React.findDOMNode(@refs.fileUpload);
     fileUploadDom.click();

  render: ->
    {div, h3, h1, input, pre} = React.DOM
    Factory = React.Factory

    RaisedButton = React.createFactory MUI.RaisedButton
    data = @state.data

    div className:'container',
      div className:'row',
        div className:'col-lg-12',
          h1 null, "Upload an xlsx file"
      div className:'row',
        div className:'col-lg-12',
          RaisedButton label:"Upload", type:'button', primary:true, onClick:@handleClick
          input ref:"fileUpload", style:{display:'none'}, type:'file', onChange:@handleFile

      if data
        div className:'row',
          div className:'col-lg-12',
            pre null, JSON.stringify(data, null, 2)
