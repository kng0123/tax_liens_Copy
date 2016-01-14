Templates.lien_upload = React.createClass
  displayName: 'LienUpload'

  handleFile: (e) ->
    files = e.target.files
    i = undefined
    f = undefined
    i = 0
    f = files[i]
    while i != files.length
      reader = new FileReader
      name = f.name

      reader.onload = (e) ->
        data = e.target.result
        workbook = XLSX.read(data,
          type: 'binary'
          cellStyles: true #To get groups
        )

        sheet = workbook.Sheets["Sheet1"]
        range = XLSX.utils.decode_range(sheet['!ref'])

        cs = range.e.c
        rs = range.e.r

        skip_rows = 2
        header_row = 3

        #Read the header row to break a row up visually
        #White(no fgColor) represents general info
        #Sequences of color bands represent grouped data
        # Checks, subsequents, etc

        r = 2
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
            group = []
            group.theme = fg_color
            groups.push(group)
          group.push(cell.w)
        rows.push(groups)

        #Merge similar groups together by object type
        #We now have an array where each element is
        # an array of objects of the same class

        #Parse each object by class
        #Each index is

        #Process the cells in a


        return

      reader.readAsBinaryString f
      ++i
    return

  handleClick: ->
     fileUploadDom = React.findDOMNode(@refs.fileUpload);
     fileUploadDom.click();

  render: ->
    {div, h3, h1, input} = React.DOM
    Factory = React.Factory

    RaisedButton = React.createFactory MUI.RaisedButton

    div className:'container',
      div className:'row',
        div className:'col-lg-12',
          h1 null, "Upload an xlsx file"
      div className:'row',
        div className:'col-lg-12',
          RaisedButton label:"Upload", type:'button', primary:true, onClick:@handleClick
          input ref:"fileUpload", style:{display:'none'}, type:'file', onChange:@handleFile
