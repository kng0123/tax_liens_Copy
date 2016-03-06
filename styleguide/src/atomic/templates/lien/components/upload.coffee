Templates.lien_upload = React.createClass
  displayName: 'LienUpload'

  getInitialState: ->
    lien_xlsx: []

  handleFile: (e) ->
    files = e.target.files
    i = 0
    f = files[i]
    while i != files.length
      reader = new FileReader
      name = f.name
      reader.onload = (e) =>
        data = e.target.result
        lien_xlsx = new App.Utils.LienXLSX(data)
        @setState lien_xlsx: lien_xlsx
        lien_xlsx.create()
      reader.readAsBinaryString f
      ++i

  handleClick: ->
     fileUploadDom = React.findDOMNode(@refs.fileUpload);
     fileUploadDom.click();

  render: ->
    {div, h3, h1, input, pre} = React.DOM
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
