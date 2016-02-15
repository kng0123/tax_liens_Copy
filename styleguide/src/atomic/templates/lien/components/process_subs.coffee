Templates.lien_process_subs = React.createClass
  displayName: 'LienProcessSubs'

  getInitialState: ->
    township: undefined
    date: '04/30/2015'

  setSubs: (e) ->
    e.preventDefault()
    e.stopPropagation()
    township = $("input[name='township']").val()
    date = $("input[name='date']").val()
    @setState(
      township: township
      date: date
    )
    return false

  goBack: ->
    @setState(
      township: undefined
      date: undefined
    )

  render: ->
    if true || @state.township and @state.date
      React.Factory.lien_process_subs_list date:@state.date, township:'Atlantic City', goBack:@goBack
    else
      React.Factory.lien_process_subs_form setSubs:@setSubs

Templates.lien_process_subs_form = React.createClass
  displayName: 'LienProcessSubsForm'

  render: ->
    {div, h3, p, form, input, span, ul, li} = React.DOM
    date_picker = React.createFactory DatePicker
    TextField = React.createFactory MUI.TextField
    RaisedButton = React.createFactory MUI.RaisedButton

    div className:'container',
      div className:'row',
        div className:'col-md-offset-4 col-md-4',
          h3 className:'strong text-center text-grey', "Specify sub list"
          div null,
            form onSubmit:@props.setSubs,
              TextField fullWidth: true, name:'township', type:'text', hintText:"Township", floatingLabelText:"Township"
              div null,
                span style:float:'left', "Sub date: "
                date_picker style:{width:'100%'}, name:'date'
              div style:{textAlign:'right', marginTop:'10px'},
                RaisedButton label:"Fetch subs list", type:'submit', primary:true

Templates.lien_process_subs_list = React.createClass
  displayName: 'LienProcessSubsList'

  getInitialState: ->
    liens: []

  componentWillMount: ->
    @queryLiens(@props)

  componentWillReceiveProps: (props)->
    @queryLiens(props)

  queryLiens: (props)->
    query = new Parse.Query(App.Models.Lien);
    query.include("subs")
    query.equalTo("county", @props.township)
    #TODO WHAT DOES THIS MEAN???
    #Principal Balance > $0
    query.notEqualTo('sub_status', 'redeemed')
    query.notEqualTo('sub_status', 'none')
    query.find({
    	success : (results) =>
        @setState liens:results
    	,
    	error : (obj, error) ->
    })

  onChange: (lien, type, sub) ->
    return (event) ->
      val = $(event.target).text()
      if sub
        sub.set('amount', parseFloat(val))
        sub.save()
      else
        data =
          type: type
          sub_date: moment("04/30/2015").toDate().toString()
          amount: parseFloat(val)
        sub = App.Models.LienSub.init_from_json(lien, data)
        lien.set('subs', lien.get('subs').concat(sub))
        lien.save()

  subDate: (lien, date, type) ->
    matches = lien.get('subs').map (sub) ->
      if sub.get('type') == type
        if date.format('MM/DD/YYYY') == moment(sub.get('sub_date')).format('MM/DD/YYYY')
          return sub
    .filter (sub) ->
      sub
    if matches.length and matches[0].get('amount')
      matches[0]

  render: ->
    {div, h3, h1, input, pre} = React.DOM
    Factory = React.Factory

    RaisedButton = React.createFactory MUI.RaisedButton

    sub_headers = ["TOWNSHIP", "BLOCK", "LOT", "QUALIFIER", "MUA ACCT 1", "CERTIFICATE #", "ADDRESS", "SALE DATE", "TAX", "UTILITY", "OTHER"]
    editable = React.createFactory PlainEditable
    sub_rows = @state.liens.map (lien, k) =>
      date = moment(@props.date)
      tax_sub = @subDate(lien, date, 'tax')
      utility_sub = @subDate(lien, date, 'utility')
      other_sub = @subDate(lien, date, 'other')

      [
        lien.get('county'),
        lien.get('block'),
        lien.get('lot'),
        lien.get('qualifier'),
        lien.get('mua_account_number'),
        lien.get('cert_number'),
        lien.get('address'),
        moment(lien.get('sale_date')).format('MM/DD/YYYY')
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'tax', tax_sub), value: if tax_sub then tax_sub.get('amount').toString()
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'utility', utility_sub), value: if utility_sub then utility_sub.get('amount').toString()
        div style:{border:'1px solid black'},
          editable onBlur:@onChange(lien, 'other', other_sub), value: if other_sub then other_sub.get('amount').toString()
      ]

    sub_table = Factory.table headers: sub_headers, rows: sub_rows

    div className:'container-fluid',
      div className:'row',
        div className:'col-lg-12',
          RaisedButton label:"Go back", onClick:@props.goBack, type:'button', primary:true
          sub_table
