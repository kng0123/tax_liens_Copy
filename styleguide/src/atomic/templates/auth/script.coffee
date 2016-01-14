
Templates.verify_email = React.createClass
  displayName: 'VerifyEmail'

  componentWillMount: ->
    @props.dispatch(Action.attempt_email_verification())

  render: ->
    {div, h3, p, form, input, span, ul, li} = React.DOM
    error = if @props.form.error
      @props.form.error.reason
    busy = @props.form.busy
    Factory = React.Factory
    Factory.pagebox null,
      h3 className:'strong text-center text-grey', "Verifying your email..."
      if error
        div className:'alert alert-danger', role:'alert',
          span className:'glyphicon glyphicon-exlamation-sign', ""
          span null, "Error: " + error


Templates.authorization = React.createClass
  displayName: 'Authorization'

  render: ->
    Factory = React.Factory
    {div} = React.DOM
    return div null
    page = switch @props.auth_link.authorization_type
      when "enroll" then Factory.enroll_account @props
      when "email_verification" then Factory.verify_email @props
      when "reset_password" then Factory.reset_password @props
    Factory.document @props,
      page
