Templates.lien_upload = React.createClass
  displayName: 'LienUpload'

  getInitialState: ->
    lien_xlsx: undefined
    uploading: false
    status: ""
    error: ""

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
        @setState({
          lien_xlsx: lien_xlsx
          uploading:false
        })
        # lien_xlsx.create()
      reader.readAsBinaryString f
      ++i

  handleCreate: ->
    @setState({
      uploading: true
      status: "Creating objects..."
    })
    @state.lien_xlsx.create().then(() =>
      @setState({
        status: "Upload complete"
      })
    ).fail((error) =>
      @setState({
        status: "Upload failed"
        error: error
      })
    )

  handleClick: ->
     fileUploadDom = React.findDOMNode(@refs.fileUpload);
     fileUploadDom.click();

  render: ->
    {div, h3, h1, input, pre, span} = React.DOM
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
      if @state.lien_xlsx
        data= @state.lien_xlsx
        div className:'row',
          div className:'col-lg-12',
            div className:'panel panel-default',
              div className:'panel-heading',
                h3 className:'panel-title',
                  span null, "Data that will be uploaded"
              div className:'panel-body',
                div style:{width:'100%'},
                  div null,
                   span null, "Townships: "
                   span null, data.townships.length
                  div null,
                   span null, "Liens: "
                   span null, data.objects.length
                  if !@state.uploading
                    div key:1,
                      RaisedButton label:"Create liens", type:'button', primary:false, onClick:@handleCreate
                  else
                    div key:1,
                      span null, @state.status
                      span null, JSON.stringify(@state.error)
