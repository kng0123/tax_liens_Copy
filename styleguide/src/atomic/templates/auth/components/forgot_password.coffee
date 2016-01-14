DumbTemplates.forgot_password = React.createClass
  displayName: 'ForgotPassword'

  getErrors: ->
    @props.schema.reduce (acc, val) ->
      acc[val.dataPath] = val.message
      return acc
    , {}

  render: ->
    {div, h3, p, form, input, span, ul, li} = React.DOM
    link = React.createFactory ReactRouter.Link
    Factory = React.Factory

    TextField = React.createFactory MUI.TextField
    RaisedButton = React.createFactory MUI.RaisedButton

    forgot_password_error = @props.forgot_password_error
    busy = @props.busy
    errors = @getErrors()

    Factory.pagebox null,
      h3 className:'strong text-center text-grey', "Sign In"
      if forgot_password_error
        div className:'alert alert-danger', role:'alert',
          span className:'glyphicon glyphicon-exlamation-sign', ""
          span null, "Error: " + forgot_password_errors
      div null,
        form onSubmit:@props.signIn.bind(@),
          TextField errorStyle:{bottom:'10px'}, fullWidth: true, name:'email',    value:@props.forgot_password_form.email, errorText:errors['/email'],    type:'email', hintText:"Email", floatingLabelText:"Email", onChange:@props.inputStream
          TextField errorStyle:{bottom:'10px'}, fullWidth: true, name:'password', value:@props.forgot_password_form.password, errorText:errors['/password'], type:'password', hintText:"Password", floatingLabelText:"Password", onChange:@props.inputStream
          div style:{textAlign:'right', marginTop:'10px'},
            RaisedButton label:"Sign in", type:'submit', disabled:busy, primary:true
        ul className:'extra-links',
          li null,
            link to:'/auth/forgot_password', "Forgot password?"
          li null,
            link to:'/auth/forgot_password', "Not registered? Sign up"

SmartTemplates.forgot_password = Recompose.compose(
  observeProps( (props$) =>
    email$ = new Rx.BehaviorSubject('')
    password$ = new Rx.BehaviorSubject('')
    busy$ = new Rx.BehaviorSubject(false)
    schema$ = new Rx.BehaviorSubject([])
    forgot_password_error$ = new Rx.BehaviorSubject('')
    form_forgot_password$ = Rx.Observable.combineLatest(
      email$, password$,
      (email, password) =>
        Object.assign({},
          forgot_password_form:
            email: email
            password: password
        )
    )

    signIn$ = RxReact.FuncSubject.create (event) ->
      event.preventDefault()
      return false

    signIn$
      .filter () ->
        schema =
          type: 'object'
          properties:
            email: type: 'string', 'check-required':1, label:'Email'
            password: type: 'string', 'check-required':1, label:'Password'
          required: ['email', 'password']
        result = tv4.validateMultiple(password: password$.value, email:email$.value, schema)
        schema$.onNext result.errors
        return result.valid
      .subscribe () ->
        props$.combineLatest (props) -> props
        .take(1)
        .subscribe (props) ->
          busy$.onNext(true)
          action = Action.attempt_forgot_password (email: email$.value, password:password$.value)
          action.subject.subscribe (result) ->
            busy$.onNext(false)
            forgot_password_error$.onNext(result.error.reason) if result.error
            forgot_password_error$.onNext("") if !result.error
          props.dispatch(action)

    inputStream$ = createEventHandler()
    inputStream$.subscribe (event) ->
      name = event.target.name
      value = event.target.value
      switch name
        when 'email' then email$.onNext(value)
        when 'password' then password$.onNext(value)

    return Rx.Observable.combineLatest(
      props$, form_forgot_password$, schema$, forgot_password_error$, busy$
      (props, form_forgot_password, schema, forgot_password_error, busy) =>
        Object.assign {},
          props,
          form_forgot_password,
          busy: busy,
          schema: schema
          signIn: signIn$,
          forgot_password_error: forgot_password_error,
          inputStream: inputStream$
    );
  )
)

Templates.forgot_password = SmartTemplates.forgot_password(DumbTemplates.forgot_password)
