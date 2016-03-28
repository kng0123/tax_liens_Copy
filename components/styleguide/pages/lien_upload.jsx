const LienUpload = React.createClass({
  displayName: 'LienUpload',

  getInitialState: function() {
    return {
      lien_xlsx: undefined,
      uploading: false,
      file: undefined,
      data: undefined,
      status: "",
      error: ""
    }
  },

  handleFile: function(e){
    var files = e.target.files
    var i = 0
    var f = files[i]
    var self = this
    var fd = new FormData()
    fd.append('file', f)
    fd.append('test', true)

    $.ajax({
      url: '/liens/import',
      data: fd,
      processData: false,
      contentType: false,
      type: 'POST',
      success: function(data){
        self.setState({
          data: data.data
        })
      }
    });
    this.setState({
      file:f,
      uploading:false,
      data: undefined
    })
  },
  handleCreate: function() {
    var fd = new FormData()
    fd.append('file', this.state.file)
    var self = this
    $.ajax({
      url: '/liens/import',
      data: fd,
      processData: false,
      contentType: false,
      type: 'POST',
      success: function(data){
        self.setState({
          data: undefined,
          status: "Upload complete"
        })
      }
    });
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
    var status = ""
    if( this.state.uploading ){
      status = <div key={1}>
        <span>{this.state.status}</span>
        <span>{JSON.stringify(this.state.error)}</span>
      </div>
    }
    if(this.state.data) {
      var data = this.state.data
      upload_status = <div className='row'>
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
                 <span>{Object.keys(this.state.data.townships).length}</span>
                </div>
                <div>
                 <span>Owners: </span>
                 <span>{Object.keys(this.state.data.owners).length}</span>
                </div>
                <div>
                 <span>Llcs: </span>
                 <span>{Object.keys(this.state.data.llcs).length}</span>
                </div>
                <div>
                 <span>Subsequents: </span>
                 <span>{data.subsequents.length}</span>
                </div>
                <div>
                 <span>Receipts: </span>
                 <span>{data.receipts.length}</span>
                </div>
                <div>
                 <span>Liens: </span>
                 <span>{data.liens.length}</span>
                </div>
              </div>
              <RaisedButton label="Create" type='button' primary={true} onClick={this.handleCreate} />
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
        {status}
        {upload_status}
      </div>
    </div>
  }
})

export default LienUpload
