DumbTemplates.sign_up = React.createClass
  displayName: 'SignUp'

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

    sign_up_error = @props.sign_up_error
    busy = @props.busy
    errors = @getErrors()

    Factory.pagebox null,
      h3 className:'strong text-center text-grey', "Sign Up"
      if sign_up_error
        div className:'alert alert-danger', role:'alert',
          span className:'glyphicon glyphicon-exlamation-sign', ""
          span null, "Error: " + sign_up_errors
      div null,
        form onSubmit:@props.signUp.bind(@),
          TextField errorStyle:{bottom:'10px'}, fullWidth: true, name:'username',    value:@props.sign_up_form.username, errorText:errors['/username'],    type:'username', hintText:"Username", floatingLabelText:"Username", onChange:@props.inputStream
          TextField errorStyle:{bottom:'10px'}, fullWidth: true, name:'password', value:@props.sign_up_form.password, errorText:errors['/password'], type:'password', hintText:"Password", floatingLabelText:"Password", onChange:@props.inputStream
          div style:{textAlign:'right', marginTop:'10px'},
            RaisedButton label:"Register", type:'submit', disabled:busy, primary:true
        ul className:'list-unstyled',
          li className:'text-center',
            link to:'/auth/sign_in', "Already registered? Sign in"

SmartTemplates.sign_up = Recompose.compose(
  observeProps( (props$) =>
    username$ = new Rx.BehaviorSubject('')
    password$ = new Rx.BehaviorSubject('')
    busy$ = new Rx.BehaviorSubject(false)
    schema$ = new Rx.BehaviorSubject([])
    sign_up_error$ = new Rx.BehaviorSubject('')
    form_sign_up$ = Rx.Observable.combineLatest(
      username$, password$,
      (username, password) =>
        Object.assign({},
          sign_up_form:
            username: username
            password: password
        )
    )

    signUp$ = RxReact.FuncSubject.create (event) ->
      event.preventDefault()
      return false

    signUp$
      .filter () ->
        schema =
          type: 'object'
          properties:
            username: type: 'string', 'check-required':1, label:'Username'
            password: type: 'string', 'check-required':1, label:'Password'
          required: ['username', 'password']
        result = tv4.validateMultiple(password: password$.value, username:username$.value, schema)
        schema$.onNext result.errors
        return result.valid
      .subscribe () ->
        props$.combineLatest (props) -> props
        .take(1)
        .subscribe (props) ->
          busy$.onNext(true)
          action = Action.attempt_sign_up (username: username$.value, password:password$.value)
          action.subject.subscribe (result) ->
            busy$.onNext(false)
            sign_up_error$.onNext(result.error.reason) if result.error
            sign_up_error$.onNext("") if !result.error
          props.dispatch(action)

    inputStream$ = createEventHandler()
    inputStream$.subscribe (event) ->
      name = event.target.name
      value = event.target.value
      switch name
        when 'username' then username$.onNext(value)
        when 'password' then password$.onNext(value)

    return Rx.Observable.combineLatest(
      props$, form_sign_up$, schema$, sign_up_error$, busy$
      (props, form_sign_up, schema, sign_up_error, busy) =>
        Object.assign {},
          props,
          form_sign_up,
          busy: busy,
          schema: schema
          signUp: signUp$,
          sign_up_error: sign_up_error,
          inputStream: inputStream$
    );
  )
)

Templates.sign_up = SmartTemplates.sign_up(DumbTemplates.sign_up)
