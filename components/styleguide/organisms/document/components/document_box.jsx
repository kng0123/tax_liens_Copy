import Header from './header.jsx'
import Page from './page.jsx'
const DocumentBox = React.createClass({
  displayName:'DocumentBox',
  contextTypes: {
    router: React.PropTypes.object
  },

  getInitialState: function() {
    return {windowWidth: window.innerWidth}
  },

  componentDidMount: function() {
    window.addEventListener('resize', this.handleResize)
  },

  componentWillUnmount: function() {
    window.removeEventListener('resize')
  },

  handleResize: function() {
    this.setState({windowWidth:window.innerWidth})
  },

  render: function() {
    return <div className='document' id='wrapper'>
      <Header {...this.props} windowWidth={this.state.windowWidth}></Header>
      <div className='document-body-container' id='page-wrapper'>
        <div className='document-body-content' style={{margin:'0 auto'}}>
          {this.props.children || Page}
        </div>
      </div>
    </div>
  }
})

export default DocumentBox
