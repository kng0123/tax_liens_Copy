Templates = @Templates = {}
DumbTemplates = @DumbTemplates = {}
SmartTemplates = @SmartTemplates = {}

Action = {
  attempt_sign_in: ({username, password}) ->
    subject = new Rx.AsyncSubject()
    action =  (dispatch, getState) ->
      Parse.User.logIn(username, password, {
        success: (user) ->
          dispatch type: 'USER_CHANGE'
          subject.onNext(error: null, response: user)
          subject.onCompleted()
          subject.dispose()
        error: (user, error) ->
          subject.onNext(error: error, response: user)
          subject.onCompleted()
          subject.dispose()
      })
    action.subject = subject
    return action
  attempt_sign_up: ({username, password}) ->
    subject = new Rx.AsyncSubject()
    action =  (dispatch, getState) ->
      Parse.User.signUp(username, password, {ACL: new Parse.ACL()}, {
        success: (user) ->
          dispatch type: 'USER_CHANGE'
          subject.onNext(error: null, response: user)
          subject.onCompleted()
          subject.dispose()
        error: (user, error) ->
          subject.onNext(error: error, response: user)
          subject.onCompleted()
          subject.dispose()
      })
    action.subject = subject
    return action

  logout: ->
    (dispatch, getState) ->
      Parse.User.logOut()
      dispatch type: 'USER_CHANGE'
}

Templates.table = React.createClass
  displayName: 'Table'

  render: ->

    Table = React.createFactory MUI.Table
    TableHeader = React.createFactory MUI.TableHeader
    TableRow = React.createFactory MUI.TableRow
    TableHeaderColumn = React.createFactory MUI.TableHeaderColumn
    TableBody = React.createFactory MUI.TableBody
    TableRowColumn = React.createFactory MUI.TableRowColumn
    RaisedButton = React.createFactory MUI.RaisedButton

    table_state = {
      fixedHeader: false,
      fixedFooter: false,
      stripedRows: false,
      showRowHover: false,
      selectable: @props.selectable,
      multiSelectable: false,
      enableSelectAll: false,
      adjustForCheckbox: false,
      deselectOnClickaway: false,
      displayRowCheckbox: false,
      height: @props.height || '600px',
    };

    table_props =
      height: table_state.height
      fixedHeader: table_state.fixedHeader
      fixedFooter: table_state.fixedFooter
      selectable: table_state.selectable
      multiSelectable: table_state.multiSelectable
      onRowSelection: @props.onRowSelection

    # debugger

    headers = @props.headers
    rows = @props.rows

    table = Table table_props,
      TableHeader adjustForCheckbox:table_state.adjustForCheckbox, enableSelectAll:table_state.enableSelectAll, displayRowCheckbox:table_state.displayRowCheckbox, displaySelectAll:false,
        TableRow null,
          headers.map (header, index) =>
            props = key:index
            if @props.widths
              props.style = {width:@props.widths[index], textAlign:'center', paddingLeft:0, paddingRight:0}
            TableHeaderColumn props, header

      TableBody deselectOnClickaway:table_state.deselectOnClickaway, showRowHover:table_state.showRowHover, stripedRows:table_state.stripedRows, displayRowCheckbox:table_state.displayRowCheckbox,
        rows.map (row, k) =>
          style = {padding:0, textAlign:'center'}
          TableRow key:k,
            row.map (item, index) =>
              props = key:index
              if @props.widths
                props.style = {width:@props.widths[index], textAlign:'center', paddingLeft:0, paddingRight:0}
              TableRowColumn  props, item

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

accounting = require('accounting')
Templates.lien = React.createClass

  displayName: 'Lien'

  getInitialState: ->
    {div} = React.DOM
    lien: undefined
    open: false
    modal: undefined
    modal_actions: div null, ""

  handleClose: ->
    @setState open: false

  openCreate: ->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.CreateReceipt) Object.assign {lien:@state.lien, callback:=>@setState open:false}, @props, ""
      # modal_actions: [React.createFactory(MUI.FlatButton) label:"Create", secondary:true, onTouchTap: @handleClose]

  getDialog: ->
    modal = @state.modal
    dialog = React.createFactory MUI.Libs.Dialog

    dialog open:@state.open, actions: @state.modal_actions, onRequestClose:@handleClose, contentStyle:{width:'500px'},
      modal

  componentWillMount: ->
    query = new Parse.Query(App.Models.Lien);
    query.equalTo("seq_id", parseInt(this.props.routeParams.id))
    query.include("subs")
    query.include("checks")
    query.include("owners")
    query.include("llcs")
    query.include("annotations")
    query.limit(1000);
    query.find({}).then( (results) =>
      @setState lien: results[0]
    )

  onChange: (item) ->
    (data) =>
      val = switch item.type
        when 'date' then moment(data.target.value).toDate()
        when 'bool' then $(data.target).is(':checked')
        when 'select' then data.value
        when 'money' then Math.round(accounting.unformat($(data.target).html()) * 100)
        else  arguments[1]

      lien = @state.lien
      old = lien.get(item.key)
      if typeof(old) == 'number'
        val = parseFloat(val)

      lien.set(item.key, val)
      @setState(lien:lien)
      @save()

  save: ->
    @state.lien.save().then (data) =>
      @setState(lien:data)
    .fail () ->

  render: ->
    {div, h3, h5, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    RaisedButton = React.createFactory MUI.RaisedButton

    lien = @state.lien
    if !lien
      return div null, ""

    state_options = [
        { value: 'redeemed', label: 'Redeemed' },
        { value: 'bankruptcy', label: 'Bankruptcy' },
        { value: 'foreclosure', label: 'Foreclosure' },
        { value: 'own', label: 'Own Home' },
        { value: 'none', label: 'No Subs' },
    ];
    select = React.createFactory Select

    if !@state.lien
      div null, ""
    else
      div null,
        @getDialog()
        div className:'container',
          div className:'row',
            div style:{width:'1200px', margin:'0 auto'},
              Factory.lien_search @props
        div className:'container',
          div className:'row',
            div className:'col-lg-12',
              div className:'container-fluid',
                h5 null,
                  span null, "LIEN #{@state.lien.get('seq_id')}"
                  React.createFactory(MUI.FlatButton) label:"Add receipt", secondary:true, onTouchTap:@openCreate
                  span style:{width:'150px', display:'inline-block'},
                    select name:'status', value:lien.get('status'), options: state_options, onChange:@onChange({type:'select', key:"status"})
                  # React.createFactory(MUI.FlatButton) label:"Add LLC", secondary:true, onTouchTap:@openCreate
          div className:'row',
            div className:'col-md-6',
              Factory.lien_info lien:lien, onChange:@onChange
            div className:'col-md-6',
              Factory.lien_cash lien:lien, onChange:@onChange
          div className:'row',
            div className:'col-md-6',
              Factory.lien_subs lien:lien, onChange:@onChange
            div className:'col-md-6',
              Factory.lien_notes lien:lien, onChange:@onChange
          div className:'row',
            div className:'col-md-12',
              Factory.lien_checks Object.assign {}, @props, lien:lien
          div className:'row',
            div className:'col-md-6',
              Factory.lien_llcs lien:lien, onChange:@onChange

Templates.formatter = React.createClass
  displayName: 'formatter'

  toggle_void: ->
    sub = this.props.value.sub
    sub.set('void', !sub.get('void'))
    sub.save()

  render: ->
    {div,p} = React.DOM
    void_state = 'clear'
    fi = React.createFactory MUI.Libs.FontIcons
    iconStyles = {
      color: '#FB8C00'
      marginRight: 10,
    };
    if(this.props.value.sub.get('void'))
      void_state = 'add'
    div null,
      fi onClick:@toggle_void, className:"muidocs-icon-action-home material-icons orange600", style:iconStyles, void_state

Templates.lien_subs = React.createClass
  displayName: 'LienSubs'

  onSubState: ->

  rowGetter: (i) ->
    sub = @props.lien.get('subs')[i]
    acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
    amount = sub.amount() || 0
    row = {
      type: sub.get('type'),
      date: moment(sub.get('sub_date')).format('MM/DD/YY'),
      amt: accounting.formatMoney(amount/100, acc_format) ,
      int: accounting.formatMoney(sub.interest()/100, acc_format) ,
      number: "",
      actions: {sub:sub}
    }
  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    lien = @props.lien

    columns = [
      {name:"TYPE", key:'type'}
      {name:"Sub date", key:'date'}
      {name:"Check #", key:'number'}
      {name:"Date paid", key:'date'}
      {name:"Amount", key:'amt'}
      {name:"Interest", key:'int'}
      {name:"Actions", key:'actions', formatter : Factory.formatter}
    ]

    sub_table = React.createFactory(ReactDataGrid) {
      columns:columns
      enableCellSelect: true
      rowGetter:@rowGetter
      rowsCount:lien.get('subs').length
      minHeight:130
    }

    div className:'panel panel-default',
      div className:'panel-heading',
        h3 className:'panel-title',
          span null, "Subsequents"
        div style:{width:'100%'},
          sub_table

Templates.lien_llcs = React.createClass
  displayName: 'LienLLCs'
  rowGetter: (i) ->
    owner = @props.lien.get('owners')[i]
    if !owner
      return {
        llc: 'No owner',
        start: moment(new Date()).format('MM/DD/YYYY'),
        end: undefined
      }
    row = {
      llc: owner.get('llc'),
      start: moment(owner.get('start_date')).format('MM/DD/YYYY'),
      end: undefined
    }
    if owner.get('end_date')
      row.end = moment(owner.get('end_date')).format('MM/DD/YYYY')
    row
  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    lien = @props.lien


    columns = [
      {name:"LLC", key:'llc'}
      {name:"Start date", key:'start'}
      {name:"End date", key:'end'}
    ]

    llc_table = React.createFactory(ReactDataGrid) {
      columns:columns
      enableCellSelect: true
      rowGetter:@rowGetter
      rowsCount:lien.get('owners').length
      minHeight:130
    }


    div className:'panel panel-default',
      div className:'panel-heading',
        h3 className:'panel-title',
          span null, "Owners"
        div style:{width:'100%'},
          llc_table

Templates.lien_check_actions = React.createClass
  displayName: 'LienCheckActions'
  toggle_void: ->
    receipt = this.props.value.receipt
    receipt.set('void', !receipt.get('void'))
    receipt.save()
  render: ->
    {div} = React.DOM
    fi = React.createFactory MUI.Libs.FontIcons
    iconStyles = {
      color: '#FB8C00'
      marginRight: 10,
    };
    void_state = 'clear'
    if(this.props.value.receipt.get('void'))
      void_state = 'add'

    div null,
      fi onClick:@props.value.onClick, className:"muidocs-icon-action-home material-icons orange600", style:iconStyles, "edit"
      fi onClick:@toggle_void, className:"muidocs-icon-action-home material-icons orange600", style:iconStyles, void_state

Templates.lien_checks = React.createClass
  displayName: 'LienChecks'

  getInitialState: ->
    {div} = React.DOM
    open: false
    modal: undefined
    modal_actions: div null, ""

  handleClose: ->
    @setState open: false

  openCreate: ->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.CreateReceipt) @props, ""
      modal_actions: [React.createFactory(MUI.FlatButton) label:"Create", secondary:true, onTouchTap: @handleClose]

  openEdit: (receipt)->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.EditReceipt) Object.assign {receipt: receipt, callback:=>@setState open:false}, @props, ""
      # modal_actions: [React.createFactory(MUI.FlatButton) label:"Edit", secondary:true, onTouchTap: @handleClose]

  getDialog: ->
    modal = @state.modal
    dialog = React.createFactory MUI.Libs.Dialog

    dialog open:@state.open, actions: @state.modal_actions, onRequestClose:@handleClose, contentStyle:{width:'400px'},
      modal


  rowGetter: (i) ->
    receipt = @props.lien.get('checks')[i]
    acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
    {
      deposit_date: moment(receipt.get('deposit_date')).format('MM/DD/YYYY')
      account: "NA"
      check_date: moment(receipt.get('check_date')).format('MM/DD/YYYY')
      check_number: receipt.get('check_number')
      redeem_date: if receipt.get('redeem_date') then moment(receipt.get('redeem_date')).format('MM/DD/YYYY') else ""
      check_amount: accounting.formatMoney(receipt.amount()/100, acc_format)
      principal: receipt.get('check_principal')
      subs: receipt.get('check_interest')
      code: receipt.get('type')
      expected_amt: accounting.formatMoney(receipt.expected_amount()/100, acc_format)
      dif: accounting.formatMoney((receipt.expected_amount() - receipt.amount())/100, acc_format)
      actions: {onClick:@openEdit.bind(@, receipt), receipt:receipt}
    }

  getColumns: () ->
    {div} = React.DOM
    fi = React.createFactory MUI.Libs.FontIcons

    columns = [
      {name:"Deposit date", key:'deposit_date'}
      {name:"Redeem date", key:'redeem_date'}
      {name:"Account", key:'account'}
      {name:"Check date", key:'check_date'}
      {name:"Check #", key:'check_number'}
      {name:"Code", key:'code'}
      {name:"Check amount", key:'check_amount'}
      {name:"Expected Amt", key:'expected_amt'}
      {name:"Dif", key:'dif'}
      {name:"Actions", key:'actions', formatter: React.Factory.lien_check_actions}
    ]

  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien

    receipt_table = React.createFactory(ReactDataGrid) {
      columns:@getColumns()
      enableCellSelect: true
      rowGetter:@rowGetter
      rowsCount:lien.get('checks').length
      minHeight:130
    }

    div className:'panel panel-default',
      div className:'panel-heading',
        # h3 className:'panel-title',
        #   span null, "Receipts"
        #   React.createFactory(MUI.FlatButton) label:"Add receipt", secondary:true, onTouchTap:@openCreate
        @getDialog()
        div style:{width:'100%'},
          receipt_table


Templates.lien_notes = React.createClass
  displayName: 'LienNotes'

  render: ->
    {div, h3, h1, ul, li, span, i, p} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien
    notes = lien.get('annotations')

    div className:'panel panel-default',
      div className:'panel-heading',
        h3 className:'panel-title', "Notes"
        ul className:'list-group', style:{height:'130px'},
          notes.map (note, key) ->
            div key:key, "BLAH"

Templates.lien_info = React.createClass
  displayName: 'LienInfo'

  render: ->
    {div, h3, h1, ul, li, span, i, p, label, fieldset, input, form,small, br} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien
    notes = lien.get('annotations')

    general_fields = [
      [{label: "Lien ID", key:"id", id:true}
      {label: "BLOCK/LOT/QUAL", key:"block_lot"}
      {label: "TOWNSHIP", key:"county", editable:false}
      {label: "CERTIFICATE #", key:"cert_number", editable:true}
      {label: "MUA ACCOUNT #", key:"mua_account_number", editable:true}
      ]

      [{label: "ADDRESS", key:"address", editable:true}
      {label: "CITY", key:"city", editable:true}
      {label: "STATE", key:"state", editable:true}
      {label: "ZIP", key:"zip", editable:true}
      {label: "REDEEM IN 10?", key:"redeem_in_10", editable:true, type:'bool'}
      ]

      [
        {label: "SALE DATE", key:"sale_date", editable:true, type:'date'}
        {label: "RECORDING DATE", key:"recording_date", editable:true, type:'date'}
        {label: "REDEMPTION DATE", key:"redemption_date", editable:true, type:'date'}

      ]
    ]

    editable = React.createFactory PlainEditable
    date_picker = React.createFactory DatePicker
    checkbox = React.createFactory MUI.Checkbox
    dp = React.createFactory Styleguide.Molecules.Forms.DatePicker
    gen_editable = (key, item, val) =>
      edit = switch(item.type)
        when 'date'
          div style:{display: 'block', position: 'relative', width: '100px'},
            dp style:{width:'150px'}, name:'redeem_date', value:val, onChange:@props.onChange(item)

        when 'bool'
          checkbox onCheck: @props.onChange(item), checked:!!val
        when 'number'
          val = accounting.toFixed(val, 2)
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
                editable onBlur:@props.onChange(item), value:val
          else
            span style:{paddingRight:'15px'}, val
        else
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
              editable onBlur:@props.onChange(item), value:val
          else
            small className:'text-muted', val || "Empty"

      fieldset style:{marginBottom:'0px'}, className:'form-group', key:key,
        div null,
          label style:{marginBottom:'0px'}, item.label
        edit

    f = React.createFactory Formsy.Form
    div className:'panel panel-default',
      div className:'panel-heading',
        f className:'container-fluid',
          div className:'row',
            general_fields.map( (fields,k) =>
              div className:'col-lg-4', key:k,
                fields.map( (field, field_key) =>
                  val = @props.lien.get(field.key)
                  if (field.id)
                    val = @props.lien.get('seq_id')

                  val = "Empty" if val is undefined and field.type != 'bool'
                  gen_editable(field_key, field, val)
                )
            )

Templates.lien_cash = React.createClass
  displayName: 'LienCash'

  render: ->
    {div, h3, h1, ul, li, span, i, p, label, fieldset, input, form,small, br} = React.DOM
    Factory = React.Factory
    #Third column from excel gui
    #lien.subs = [{type:'check'}, {type:'check'}]
    lien = @props.lien

    notes = lien.get('annotations')

    #Second column from excel GUI
    fields = [

      [
        {label: "WINNING RATE", key:"winning_bid", editable:true}
        {label: "RECORDING FEE", key:"recording_fee", editable:true, type:'money'}
        {label: "SEARCH FEE", type:'money', key:"search_fee", is_function:true, editable:true}
        {label: "YEAR END PENALTY", key:"2013_yep", editable:true, type:'money'}
        {label: "FACE VALUE", key:"cert_fv", editable:false, type:'money'}
      ]
      [
        {label: "PREMIUM", key:"premium", editable:false, type:'money'}
        {label: "PRINCIPAL BALANCE", key:"principal_balance", is_function:true, type:'money'}
        {label: "TOTAL PAID", key:"total_paid", editable:false, type:'money'}
        {label: "FLAT RATE", key:"flat_rate", is_function:true, type:'money'}
        {label: "CERT INT", key:"cert_interest", is_function:true, type:'money'}
      ]
      [


        # {label: "REDEMPTION AMOUNT", key:"redemption_amt", editable:true, type:'number'}
        {label: "TOTAL CASH OUT", key:"total_cash_out", is_function:true, type:'money'}
        {label: "TOTAL INT DUE", key:"total_interest_due", is_function:true, type:'money'}
        #TODO Calculate expected amt
        {label: "REDEMPTION AMT", key:"county_redemption_amt", editable:true, type:'money'}
        {label: "EXPECTED AMT", key:"expected_amount", is_function:true, type:'money'}
        #TODO: No longer required
        # {label: "MZ CHECK", type:'money', key:"total_check", is_function:true}
        {label: "DIFFERENCE", key:"diff", is_function:true, type:'money'}
      ]
    ]

    editable = React.createFactory PlainEditable
    date_picker = React.createFactory DatePicker
    checkbox = React.createFactory MUI.Checkbox

    gen_editable = (key, item, val) =>
      edit = switch(item.type)
        when 'date'
          div style:{display: 'block', position: 'relative', width: '100px'},
            date_picker className:'form-control datepicker', selected:moment(val), onChange:@props.onChange(item)
        when 'bool' then checkbox onCheck: @props.onChange(item), checked:!!val
        when 'money'
          val = accounting.formatMoney(val/100, {symbol : "$", decimal : ".", precision : 2, format: "%s%v"})
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
                editable onBlur:@props.onChange(item), value:val
          else
            span style:{paddingRight:'15px'}, val
        when 'number'
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
                editable onBlur:@props.onChange(item), value:val
          else
            span style:{paddingRight:'15px'}, val
        else
          if item.editable
            span style:{display:'inline-block', minWidth:'100px', paddingRight:'10px'},
              editable onBlur:@props.onChange(item), value:val
          else
            small className:'text-muted', val || "Empty"

      fieldset style:{marginBottom:'0px'}, className:'form-group', key:key,
        div null,
          label style:{marginBottom:'0px'}, item.label
        edit

    div className:'panel panel-default',
      div className:'panel-heading',
        form className:'container-fluid',
          div className:'row',
            fields.map( (fields,k) =>
              div className:'col-lg-4', key:k,
                fields.map( (field, field_key) =>
                  val = if @props.lien.get(field.key) is undefined
                    ""
                  else
                    @props.lien.get(field.key)
                  if val instanceof Date
                    val = moment(val).format('MM/DD/YYYY');
                  if typeof val is 'number'
                    val = val.toString()
                  if field.is_function
                    val = @props.lien[field.key]().toString()
                  val = "Empty" if val is undefined
                  gen_editable(field.key, field, val)
                )
            )

Templates.lien_list = React.createClass
  displayName: 'LienList'
  contextTypes: {
    router: React.PropTypes.object
  },
  getInitialState: ->
    liens: []
    open: false
    modal: undefined

  handleClose: ->
    @setState open: false

  exportReceipts: ->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.ExportReceipts) Object.assign {liens:@state.liens, callback:=>@setState open:false}, @props, ""
  exportLiens: ->
    @setState
      open: true
      modal: React.createFactory(Styleguide.Organisms.Lien.ExportLiens) Object.assign {liens:@state.liens, callback:=>@setState open:false}, @props, ""

  getDialog: ->
    modal = @state.modal
    dialog = React.createFactory MUI.Libs.Dialog
    dialog open:@state.open, actions: @state.modal_actions, onRequestClose:@handleClose, contentStyle:{width:'500px'},
      modal

  componentWillMount: ->
    @queryLiens(@props)

  componentWillReceiveProps: (props)->
    @queryLiens(props)

  queryLiens: (props)->
    query_params = props.search
    query = new Parse.Query(App.Models.Lien);
    if !query_params
      return
    if query_params.id
      query.equalTo("seq_id", query_params.id)
    else if query_params.block
      query.equalTo("block", query_params.block)
      query.equalTo("lot", query_params.lot) if query_params.lot
      query.equalTo("qualifier", query_params.qualifier) if query_params.qualifier
    else if query_params.cert
      query.equalTo("cert_number", query_params.cert)
    else if query_params.sale_year
      year = parseInt(query_params.sale_year)
      query.greaterThan("sale_date", moment([year, 0]).toDate());
      query.lessThan("sale_date", moment([year+1, 0]).toDate());
    else if query_params.township
      query.contains("county", query_params.township)
    else
      return

    #TODO What to do with case #?
    query.include("subs")
    query.include("checks")
    query.include("owners")
    query.include("llcs")
    query.include("annotations")
    query.limit(1000);
    query.find({
    	success : (results) =>
        @setState liens:results
    	,
    	error : (obj, error) ->

    })

  goToLien: (indices) ->
    lien = @state.liens[indices[0]]
    @context.router.push('/lien/item/'+lien.get('seq_id'))


  render: ->
    {div, h3, h1, p} = React.DOM
    Factory = React.Factory
    RaisedButton = React.createFactory MUI.RaisedButton

    sub_headers = ["ID", "TOWNSHIP", "BLOCK", "LOT", "QUALIFIER", "MUA ACCT 1", "CERTIFICATE #", "ADDRESS", "SALE DATE"]
    editable = React.createFactory PlainEditable
    sub_rows = @state.liens.map (lien, k) =>
      [
        lien.get('seq_id'),
        div onClick:@goToLien, 'data-id':lien.get('seq_id'), lien.get('county')
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).format('MM/DD/YYYY')
      ]

    widths = ['40px', '20px','20px','30px','50px','50px','50px','50px','50px','50px']

    sub_table = Factory.table widths:widths, selectable:true, headers: sub_headers, rows: sub_rows, onRowSelection:@goToLien

    div null,
      @getDialog()
      div className:'container-fluid',
        div className:'row',
          div style:{width:'1200px', margin:'0 auto'},
            Factory.lien_search @props
      div className:'container-fluid',
        div className:'row',
          if @state.liens.length
            div className:'col-lg-12',
              React.createFactory(MUI.FlatButton) label:"Export receipts", secondary:true, onTouchTap:@exportReceipts
              React.createFactory(MUI.FlatButton) label:"Export liens", secondary:true, onTouchTap:@exportLiens
        div className:'row',
          div className:'col-lg-12',
            if @state.liens.length
              sub_table
            else
              p null, "No liens found. Try uploading some."

Paper = require('material-ui/lib/paper');
Templates.lien_process_subs = React.createClass
  displayName: 'LienProcessSubs'

  setSubs: (e) ->
    e.preventDefault()
    e.stopPropagation()
    township = $("input[name='township']").val()
    date = $("input[name='date']").val()
    data =
      township: township
      date: date
    @props.dispatch(ReduxRouter.pushState(null, @props.location.pathname, data))
    return false

  render: ->
    state = @props.location.query
    if state.township and state.date
      React.Factory.lien_process_subs_list date:state.date, township:state.township, goBack:@goBack
    else
      React.Factory.lien_process_subs_form setSubs:@setSubs

Templates.lien_process_subs_form = React.createClass
  displayName: 'LienProcessSubsForm'

  contextTypes: {
    router: React.PropTypes.object
  },

  getInitialState: () ->
    data: {
      township: undefined
    }
    townships: []
    batches: []
    batch_date: new Date()

  componentDidMount: () ->
    township_query = new Parse.Query('Township');
    township_query.find().then( (townships) =>
      @setState townships:townships.map( (township) ->
        label: township.get('township'), value:township
      )
    )
    @fetchBatches()

  fetchBatches: (township) ->
    batch_query = new Parse.Query('SubBatch');
    if township
      batch_query.equalTo('township', township)
    return batch_query.find().then( (batches) =>
      @setState batches:batches
    )

  onChange: (event) ->
    @setState data:{township:event.value}
    @fetchBatches(event.value)

  goToBatch: (indices) ->
    batch = @state.batches[indices[0]]
    @context.router.push('/lien/batch/'+batch.id)

  updateBatchDate: (event) ->
    @setState batch_date: new Date(event.target.value)

  createBatch: (event) ->
    query = new Parse.Query(App.Models.Lien);
    query.include("subs")
    query.equalTo("township", @state.data.township)
    #TODO WHAT DOES THIS MEAN???
    #Principal Balance > $0
    query.notContainedIn('status', ['redeemed', 'none'])
    query.limit(1000);
    query.find({
    	success : (liens) =>
        batch = {
          sub_date: @state.batch_date,
          township: @state.data.township,
          subs: [],
          liens: liens
        }
        App.Models.SubBatch.init_from_json(batch).save()
        .then( (batch) =>
          @context.router.push('/lien/batch/'+batch.id)
        )
    	,
    	error : (obj, error) ->
    })


  valueRenderer: (val) ->
    {div, h3, p, form, input, span, ul, li, button} = React.DOM
    if val
      val.get('township')

  render: ->
    {div, h3, p, form, input, span, ul, li, button} = React.DOM
    TextField = React.createFactory MUI.TextField
    RaisedButton = React.createFactory MUI.RaisedButton
    Paper = React.createFactory Paper
    paperStyle=  {
      width: 450,
      margin: '20px auto',
      padding: 20
    }

    select = React.createFactory Select

    Factory = React.Factory

    RaisedButton = React.createFactory MUI.RaisedButton

    batch_headers = ["TOWNSHIP", "DATE"]
    editable = React.createFactory PlainEditable
    batch_rows = @state.batches.map (batch, k) =>
      [
        batch.get('township').get('township')
        moment(batch.get('sub_date')).format('MM/DD/YYYY')
      ]
    # widths = ['40px', '20px','20px','30px','50px','50px','50px','50px','50px','50px','50px','50px','50px']

    batch_table = Factory.table selectable: true, onRowSelection:@goToBatch, headers: batch_headers, rows: batch_rows
    val = ""
    if @state.data.township
      val = @state.data.township
    date_picker = React.createFactory DatePicker
    RaisedButton = React.createFactory MUI.RaisedButton
    f = React.createFactory Formsy.Form
    dp = React.createFactory Styleguide.Molecules.Forms.DatePicker
    div className:'container',
      div className:'row',
        div className:'col-md-offset-4 col-md-4',
          h3 className:'strong text-center text-grey', "Specify sub list"
          div style:paperStyle,
            form
              select name:'township', style:{width:'360px'}, value:val, options:@state.townships, onChange:@onChange, valueRenderer:@valueRenderer
      div className:'row',
        div className:'col-sm-12',
          p null, "Recent Subsequents"
          f className:'form-inline', onValidSubmit:@createBatch,
            div className:'form-group',
              div style:{float:'left', width:'160px'},
                div style:{display: 'block', position: 'relative', width: '100px'},
                  dp style:{width:'150px'}, name:'redeem_date', value:moment(@state.batch_date), onChange:@updateBatchDate
              div style:{float:'left'},
                select name:'township', style:{width:'200px'}, value:val, options:@state.townships, onChange:@onChange, valueRenderer:@valueRenderer
              RaisedButton label:"Create new batch", onClick:@logout, type:'submit', disabled:!(val.id && @state.batch_date), primary:true
        div className:'col-sm-12',
          batch_table

Templates.lien_process_subs_list = React.createClass
  displayName: 'LienProcessSubsList'
  contextTypes: {
    router: React.PropTypes.object
  },
  getInitialState: ->
    batch: undefined

  componentWillMount: ->
    query = new Parse.Query(App.Models.SubBatch);
    query.equalTo("objectId", this.props.routeParams.id)
    query.include("subs")
    query.include("liens")
    query.find({}).then( (results) =>
      batch = results[0]
      @setState(
        batch: batch
        subs: batch.get('subs').reduce( (m, sub) ->
          m[sub.id] = sub
          return m
        , {})
      )
    )

  onChange: (lien, type, sub) ->
    return (event) =>
      val = $(event.target).text() || 0
      val = Math.round(accounting.unformat(val) * 100)

      if sub.get('lien')
        sub.set('amount', parseFloat(val))
        sub.save()
      else
        data =
          type: type
          sub_date: @state.batch.get('sub_date').toString()
          amount: $(event.target).text()
        sub = App.Models.LienSub.init_from_json(lien, data)

        lien.set('subs', lien.get('subs').concat(sub))
        lien.save().then(() =>
          @state.batch.addSub(sub)
          @state.batch.save()
        ).fail(()->
          debugger
        )


  goToLien: (event) ->
    id = event.target.dataset.id
    @context.router.push('/lien/item/'+id)

  toggleVoid: ->
    batch = @state.batch

    void_state = !!batch.get('void')
    batch.set('void', !void_state)
    batch.get('subs').map( (sub) ->
      sub.set('void', !void_state)
    )
    batch.save().then (batch) =>
      @setState batch:batch

  subDate: (lien, date, type) ->
    matches = lien.get('subs').map (sub) ->
      if sub.get('type') == type
        if date.format('MM/DD/YYYY') == moment(sub.get('sub_date')).format('MM/DD/YYYY')
          return sub
    .filter (sub) ->
      sub
    if matches.length and matches[0].get('amount')
      matches[0]

  exportXLSX: ->
    Workbook = ->
      if !(this instanceof Workbook)
        return new Workbook
      @SheetNames = []
      @Sheets = {}
      return

    wb = new Workbook
    ws_name = 'SheetJS'
    #TODO DEFINE DATA

    data = [
      ["SUB REQUEST"]
      ["Interest Date: #{moment(@state.batch.get('sub_date')).format('MM/DD/YYYY')}"]
      ["Township", "Block", "Lot", "Qualifier", "MUA Acct 1", "Certificate #", "Address", "Sale Date", "Tax Amount", "Utility Amount", "Other Amount"]
    ]
    rows = @state.batch.get('liens').map (lien, k) =>
      date = moment(@props.date)
      subs = lien.get('subs').map( (sub) =>
        @state.subs[sub.id]
      )
      subs = subs.reduce( (m, sub) =>
        if sub
          m[sub.get('type')] = sub
        return m
      , {})
      tax_sub = subs['tax']
      utility_sub = subs['utility']
      other_sub = subs['other']
      acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
      tax_amount = accounting.formatMoney(tax_sub.get('amount')/100, acc_format) if tax_sub
      util_amount = accounting.formatMoney(utility_sub.get('amount')/100, acc_format) if utility_sub
      other_amount = accounting.formatMoney(other_sub.get('amount')/100, acc_format) if other_sub
      [
        lien.get('county'),
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).toDate()
        (if tax_sub then tax_amount || "" else "")
        (if utility_sub then util_amount || "" else "")
        (if other_sub then other_amount || "" else "")
      ]
    data= data.concat rows
    ws = convert_to_xlsx_json(data)
    wb.SheetNames.push ws_name
    wb.Sheets[ws_name] = ws

    #Add formating to the sheet
    cols = [
      {"width":"17.140625","customWidth":"1","wpx":120,"wch":16.43,"MDW":7},
      {"width":"6","bestFit":"1","customWidth":"1","wpx":42,"wch":5.29,"MDW":7},
      {"width":"5.140625","customWidth":"1","wpx":36,"wch":4.43,"MDW":7},
      {"width":"7.7109375","bestFit":"1","customWidth":"1","wpx":54,"wch":7,"MDW":7},
      {"width":"18.85546875","bestFit":"1","customWidth":"1","wpx":132,"wch":18.14,"MDW":7},
      {"width":"10.42578125","bestFit":"1","customWidth":"1","wpx":73,"wch":9.71,"MDW":7},
      {"width":"25.28515625","bestFit":"1","customWidth":"1","wpx":177,"wch":24.57,"MDW":7},
      {"width":"10.42578125","bestFit":"1","customWidth":"1","wpx":73,"wch":9.71,"MDW":7},
      {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7},
      {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7},
      {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7}
    ]
    cols = cols.map( (col) =>
      arr = []
      Object.keys(col).map (key) ->
        arr[key] = col[key]
      return arr
    )
    merges = [{"s":{"c":0,"r":0},"e":{"c":10,"r":0}}]
    ws['!cols'] = cols
    ws['!merges'] = merges
    #TODO Styling does not work
    styles = [
      {"numFmtId":0,"fontId":"0","fillId":0,"borderId":"0","xfId":"0"},
      {"numFmtId":0,"fontId":"2","fillId":0,"borderId":"1","xfId":"0","applyFont":"1","applyFill":"1","applyBorder":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"3","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"1","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"4","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"5","fillId":0,"borderId":"2","xfId":"0","applyFont":"1","applyBorder":"1"},
      {"numFmtId":14,"fontId":"5","fillId":0,"borderId":"2","xfId":"0","applyNumberFormat":"1","applyFont":"1","applyBorder":"1"},
      {"numFmtId":0,"fontId":"0","fillId":0,"borderId":"2","xfId":"0","applyBorder":"1"}
    ]
    styles = cols.map( (col) =>
      arr = [undefined]
      Object.keys(col).map (key) ->
        arr[key] = col[key]
      return arr
    )
    # ws['!ref'] = "A1:K52"
    wb.Styles = CellXf: styles
    wbout = XLSX.write(wb,
      bookType: 'xlsx'
      bookSST: true
      type: 'binary')

    #Sheet to a buffer - s2ab
    s2ab = (s) ->
      buf = new ArrayBuffer(s.length)
      view = new Uint8Array(buf)
      i = 0
      while i != s.length
        view[i] = s.charCodeAt(i) & 0xFF
        ++i
      buf
    saveAs new Blob([ s2ab(wbout) ], type: 'application/octet-stream'), 'test.xlsx'
  render: ->
    {div, h3, h1, input, pre,p} = React.DOM
    Factory = React.Factory
    if !@state.batch
      return div null, "Loading..."

    RaisedButton = React.createFactory MUI.RaisedButton

    sub_headers = ["TOWNSHIP", "BLOCK", "LOT", "QUALIFIER", "MUA ACCT 1", "CERTIFICATE #", "ADDRESS", "SALE DATE", "TAX", "UTILITY", "OTHER"]
    editable = React.createFactory PlainEditable
    sub_rows = @state.batch.get('liens').map (lien, k) =>
      date = moment(@props.date)
      sub_date = ""
      subs = []
      if lien.get('subs')
        subs = lien.get('subs').map( (sub) =>
          @state.subs[sub.id]
        )
      subs = subs.reduce( (m, sub) =>
        if sub
          sub_date = sub.get('sub_date')
          m[sub.get('type')] = sub
        return m
      , {})
      tax_sub = subs['tax'] || new App.Models.LienSub({type:'tax', sub_date:sub_date})
      utility_sub = subs['utility'] || new App.Models.LienSub({type:'utility', sub_date:sub_date})
      other_sub = subs['other'] || new App.Models.LienSub({type:'other', sub_date:sub_date})
      acc_format = {symbol : "$", decimal : ".", precision : 2, format: "%s%v"}
      tax_amount = accounting.formatMoney(tax_sub.get('amount')/100, acc_format)
      util_amount = accounting.formatMoney(utility_sub.get('amount')/100, acc_format)
      other_amount = accounting.formatMoney(other_sub.get('amount')/100, acc_format)

      [
        div onClick:@goToLien, 'data-id':lien.get('seq_id'), lien.get('county')
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).format('MM/DD/YYYY')
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'tax', tax_sub), value: if tax_sub.get('amount') then tax_amount
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'utility', utility_sub), value: if utility_sub.get('amount') then util_amount
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'other', other_sub), value: if other_sub.get('amount') then other_amount
      ]

    widths = ['40px', '20px','20px','30px','50px','50px','50px','50px','50px','50px','50px','50px','50px']

    sub_table = Factory.table widths:widths, selectable:false, headers: sub_headers, rows: sub_rows

    void_label = "Void"

    if @state.batch.get('void')
      void_label = "Un-Void"
    div className:'container-fluid',
      div className:'row',
        div className:'col-lg-12',
          p null, "Interest for #{moment(@state.batch.get('sub_date')).format('MM/DD/YYYY')}"
        div className:'col-lg-12',
          RaisedButton label:"Export Excel", onClick:@exportXLSX, type:'button', primary:true
          RaisedButton label:void_label, onClick:@toggleVoid, type:'button', primary:false
          sub_table


### original data ###
### add worksheet to workbook ###

datenum = (v, date1904) ->
  if date1904
    v += 1462
  epoch = Date.parse(v)
  (epoch - (new Date(Date.UTC(1899, 11, 30)))) / (24 * 60 * 60 * 1000)

convert_to_xlsx_json = (data, opts) ->
  `var ws`
  ws = {}
  range =
    s:
      c: 10000000
      r: 10000000
    e:
      c: 0
      r: 0
  R = 0;
  while R != data.length
    C = 0
    while C != data[R].length
      if range.s.r > R
        range.s.r = R
      if range.s.c > C
        range.s.c = C
      if range.e.r < R
        range.e.r = R
      if range.e.c < C
        range.e.c = C
      cell = v: data[R][C]
      if cell.v == null
        ++C
        continue
      cell_ref = XLSX.utils.encode_cell(
        c: C
        r: R)
      if typeof cell.v == 'number'
        cell.t = 'n'
      else if typeof cell.v == 'boolean'
        cell.t = 'b'
      else if cell.v instanceof Date
        cell.t = 'n'
        cell.z = XLSX.SSF._table[14]
        cell.v = datenum(cell.v)
      else
        cell.t = 's'
      if R < 3
        cell.h = cell.v
        cell.w = cell.v
        cell.r = "<t>#{cell.v}</t>"
      ws[cell_ref] = cell
      ++C
    ++R
  if range.s.c < 10000000
    ws['!ref'] = XLSX.utils.encode_range(range)
  ws

Templates.lien_search = React.createClass
  displayName: 'LienSearch'

  contextTypes: {
    router: React.PropTypes.object
  },

  getInitialState: ->
    townships: []
    data: Object.assign {}, @props.search

  componentWillMount: () ->
    query = new Parse.Query('Township');
    return query.find().then( (townships) =>
      @setState townships:townships.map( (township) ->
        label: township.get('township'), value:township.get('township')
      )
    )

  componentWillReceiveProps: (props)->
    @setState data: props.search

  onChange: (event) ->
    if event.label
      data = @state.data
      data['township'] = event.value
      @setState data: data
    else
      name = event.target.name
      val = event.target.value

      data = @state.data
      data[name] = val
      @setState data: data

  onSubmit: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @context.router.push(
      pathname: '/lien',
      query: @state.data
    )
    this.props.dispatch({type:'SEARCH', data:@state.data})
    return false

  render: ->
    {form, div, label, input, button, span} = React.DOM
    inputs = [
        label: "Block", type:'text', key:'block'
      ,
        label: "Lot", type:'text', key:'lot'
      ,
        label: "Qual", type:'text', key:'qualifier'
      ,
        label: "Certificate #", type:'text', key:'cert'
      ,
        label: "Sale year", type:'text', key:'sale_year'
      ,
        label: "Township", type:'text', key:'township'
      ,
        label: "Case #", type:'text', key:'case'
      ,
        label: "Lien ID", type:'text', key:'id'
    ]

    select = React.createFactory Select

    form className:'form-inline', onSubmit:@onSubmit,
      inputs.map (item, index) =>
        div key:index, className:'form-group',
          div style:{display:'block'},
            div null,
              span null, item.label
            if item.key != 'township'
              input onChange:@onChange, style:{width:'130px'}, type:item.type, name:item.key, value:@state.data[item.key], className:'form-control'
            else
              select name:'status', style:{width:'130px'},value:@state.data[item.key], name:item.key, options:@state.townships, onChange:@onChange
      button type:'submit', style:{marginTop:'20px', marginLeft:'10px'}, className:'btn btn-primary', "Go"

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

tv4.setErrorReporter (error, data, schema) ->
  switch error.code
    when tv4.errorCodes.OBJECT_REQUIRED then "#{schema.label} is required"

tv4.defineKeyword 'check-required', (data, props, schema) ->
  if !data
    return code:tv4.errorCodes.OBJECT_REQUIRED, message:{}

DumbTemplates.header = React.createClass
  displayName: 'Header'

  contextTypes: {
    router: React.PropTypes.object
  },

  logout: ->
    @props.dispatch(Action.logout())

  login: ->
    @context.router.push('/auth/sign_in')

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

    linkStyles = {lineHeight:'56px', marginRight:'10px'}

    Toolbar style:{marginBottom:'10px'},
      ToolbarGroup null,
        ToolbarTitle text:'TTG Lien'
      ToolbarGroup null,
        if @props.user.id
          div null,
            link style:linkStyles, to:'/', 'Home'
            link style:linkStyles, to:'/lien/upload', 'Upload'
            link style:linkStyles, to:'/lien/subs', 'Batch subs'
        else
          div null,
            link style:linkStyles, to:'/', 'Home'

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

  contextTypes: {
    router: React.PropTypes.object
  },

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
        div className:'document-body-content', style:{margin:'0 auto'},
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

React.Factory = {}
for x, y of Templates
  React.Factory[x] = React.createFactory y
