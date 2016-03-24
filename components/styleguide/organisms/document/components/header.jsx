const Header = React.createClass({
  contextTypes: {
    router: React.PropTypes.object
  },
  logout: function() {
    this.props.dispatch(Action.logout())
  },

  login: function() {
    this.context.router.push('/auth/sign_in')
  },

  render: function() {
    var Link = ReactRouter.Link
    var user_email = "test"
    var logged_in = this.props.user.id
    var RaisedButton = MUI.RaisedButton

    var Toolbar = MUI.Toolbar
    var ToolbarGroup = MUI.ToolbarGroup
    var ToolbarSeparator = MUI.ToolbarSeparator
    var ToolbarTitle = MUI.ToolbarTitle

    var linkStyles = {lineHeight:'56px', marginRight:'10px'}
    var navigation = <div><Link style={linkStyles} to='/'>{'Home'}</Link></div>
    var auth_button = <RaisedButton label={"Log out"} onClick={this.logout} type={'button'} disabled={false} primary={true} />
    if(logged_in) {
      navigation = <div>
        <Link style={linkStyles} to='/'>Home</Link>
        <Link style={linkStyles} to='/lien/upload'>Upload</Link>
        <Link style={linkStyles} to='/lien/subs'>Batch subs</Link>
      </div>
      auth_button = <RaisedButton label={"Log in"} onClick={this.login} type={'button'} disabled={false} primary={true} />
    }

    return <Toolbar style={{marginBottom:'10px'}}>
      <ToolbarGroup>
        <ToolbarTitle text='TTG Lien'/>
      </ToolbarGroup>
      <ToolbarGroup>
        {navigation}
      </ToolbarGroup>
      <ToolbarGroup float='right'>
        <ToolbarSeparator />
        {auth_button}
      </ToolbarGroup>
    </Toolbar>
  }
})

export default Header
