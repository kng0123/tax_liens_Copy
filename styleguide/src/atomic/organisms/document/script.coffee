DumbTemplates.header = React.createClass
  displayName: 'Header'

  logout: ->
    @props.dispatch(Action.logout())

  login: ->
    @props.dispatch(ReduxRouter.pushState(null, '/auth/sign_in'))

  render: ->
    {div, button, p, span, a, ul, li, nav} = React.DOM
    link = React.createFactory ReactRouter.Link

    user_email = "test"
    logged_in = @props.user.id
    RaisedButton = React.createFactory MUI.RaisedButton

    Toolbar = React.createFactory MUI.Toolbar
    ToolbarGroup = React.createFactory MUI.ToolbarGroup
    ToolbarSeparator = React.createFactory MUI.ToolbarSeparator
    ToolbarTitle = React.createFactory MUI.ToolbarTitle

    Toolbar style:{marginBottom:'10px'},
      ToolbarGroup null,
        ToolbarTitle text:'TTG Lien'
      ToolbarGroup null,
        link style:{lineHeight:'56px'}, to:'/', 'Home'
      ToolbarGroup float:'right',
        ToolbarSeparator null
        if logged_in
          RaisedButton label:"Log out", onClick:@logout, type:'button', disabled:false, primary:true
        else
          RaisedButton label:"Log in", onClick:@login, type:'button', disabled:false, primary:true

SmartTemplates.header = Recompose.compose(
)
Templates.header = SmartTemplates.header DumbTemplates.header
Templates.footer = React.createClass
  displayName: 'Footer'

  render: ->
    {div, p} = React.DOM
    div className:'document-footer-container',
      p null, "Footer"

Templates.document = React.createClass
  displayName: 'Documnet'

  getInitialState: ->
    windowWidth: window.innerWidth

  componentDidMount: ->
    window.addEventListener('resize', @handleResize)

  componentWillUnmount: ->
    window.removeEventListener('resize')

  handleResize: ->
    @setState windowWidth:window.innerWidth

  render: ->
    {div, h1, p} = React.DOM
    Factory = React.Factory

    $(".document-header-container").height()
    div className:'document', id:'wrapper',
      Factory.header Object.assign({}, @props, {windowWidth:@state.windowWidth}), ""
      div className: 'document-body-container', id:'page-wrapper',
        div className:'document-body-content',
          this.props.children || Factory.page


Templates.document_box = React.createClass
  displayName: 'DocumnetBox'

  getInitialState: ->
    windowWidth: window.innerWidth

  componentDidMount: ->
    window.addEventListener('resize', @handleResize)

  componentWillUnmount: ->
    window.removeEventListener('resize')

  handleResize: ->
    @setState windowWidth:window.innerWidth

  render: ->
    {div, h1, p} = React.DOM
    Factory = React.Factory

    $(".document-header-container").height()
    div className:'document', id:'wrapper',
      Factory.header Object.assign({}, @props, {windowWidth:@state.windowWidth}), ""
      div className: 'document-body-container', id:'page-wrapper',
        div className:'document-body-content', style:{margin:'0 auto', width:'400px', border:'1px solid black', padding:'10px'},
          this.props.children || Factory.page

Templates.loading_document = React.createClass
  displayName: 'LoadingDocumnet'
  render: ->
    {div, h4} = React.DOM
    Factory = React.Factory
    Factory.document @props,
      Factory.pagebox @props,
        div style:{margin:'0 auto'}, className:'sprite sprite-icon', ""
        h4 className:'text-center', "Welcome!"

Templates.page = React.createClass
  displayName: 'page'

  render: ->
    {div, h1, p} = React.DOM
    div className: 'page-container',
      div className: 'page-content',
        this.props.children || "Content"

Templates.pagebox = React.createClass
  displayName: 'pagebox'

  render: ->
    {div, h1, p} = React.DOM
    div className: 'page-container',
      div className: 'page-content',
        div className: 'page-box', style: @props.style,
          this.props.children || "Content"
