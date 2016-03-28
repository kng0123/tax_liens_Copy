const LienUpload = React.createClass({
  displayName: 'LienUpload',

  getInitialState: function() {
    return {
      lien_xlsx: undefined,
      uploading: false,
      status: "",
      error: ""
    }
  },

  handleFile: function(e){
    var files = e.target.files
    var i = 0
    var f = files[i]
    var self = this
    while(i != files.length) {
      var reader = new FileReader()
      var name = f.name
      reader.onload = function(e) {
        var data = e.target.result
        var lien_xlsx = new App.Utils.LienXLSX(data)
        self.setState({
          lien_xlsx: lien_xlsx,
          uploading:false
        })
      }
      reader.readAsBinaryString(f)
      ++i
    }
  },
  handleCreate: function() {
    var self = this
    self.setState({
      uploading: true,
      status: "Creating objects..."
    })
    // self.dstate.lien_xlsx.create().then(() =>
    //   self.setState({
    //     status: "Upload complete"
    //   })
    // ).fail((error) =>
    //   @setState({
    //     status: "Upload failed"
    //     error: error
    //   })
    // )
  },
  handleClick: function() {
    var fileUploadDom = React.findDOMNode(this.refs.fileUpload);
    fileUploadDom.click();
  },

  render: function() {
    var RaisedButton = MUI.RaisedButton

    var upload_status = <div></div>
    if(this.state.lien_xlsx) {
      var status = <div key={1}>
        <RaisedButton label="Create liens" type='button' primary={false} onClick={this.handleCreate} />
      </div>
      if( this.state.uploading ){
        status = <div key={1}>
          <span>{this.state.status}</span>
          <span>{JSON.stringify(this.state.error)}</span>
        </div>
      }
      <div className='row'>
        <div className='col-lg-12'>
          <div className='panel panel-default'>
            <div className='panel-heading'>
              <h3 className='panel-title'>
                <span>Data that will be uploaded</span>
              </h3>
            </div>
            <div className='panel-body'>
              <div style={{width:'100%'}}>
                <div>
                 <span>Townships: </span>
                 <span>{data.townships.length}</span>
                </div>
                <div>
                 <span>Liens: </span>
                 <span>{data.objects.length}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    }
    return <div className='container'>
        <div className='row'>
          <div className='col-lg-12'>
            <h1>Upload an xlsx file</h1>
          </div>
        <div className='row'>
          <div className='col-lg-12'>
            <RaisedButton label="Upload" type='button' primary={true} onClick={this.handleClick} />
            <input ref="fileUpload" style={{display:'none'}} type='file' onChange={this.handleFile} />
          </div>
        </div>
        {upload_status}
      </div>
    </div>
  }
})

export default LienUpload
