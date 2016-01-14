Templates.lien = React.createClass
  displayName: 'Lien'

  getInitialState: ->
    lien: {}

  componentWillMount: ->
    Lien = Parse.Object.extend("Lien");
    query = new Parse.Query(Lien);
    query.equalTo("objectId", this.props.routeParams.id)
    query.find({
    	success : (results) =>
    		@setState lien: results[0]._toFullJSON()
    	,
    	error : (obj, error) ->
    })

  render: ->
    {div, h3, h1} = React.DOM
    Factory = React.Factory

    div className:'container',
      div className:'row',
        div className:'col-lg-12',
          h1 null, "LIEN #{@state.lien.unique_id}"
      div className:'row',
        div className:'col-sm-4',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "Identification"
            div className:'panel-body', "Panel content"

        div className:'col-sm-4',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "Purchaser"
            div className:'panel-body', "Panel content"

        div className:'col-sm-4',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "Terms"
            div className:'panel-body', "Panel content"

        div className:'col-sm-4',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "Receipts"
            div className:'panel-body', "Panel content"

        div className:'col-sm-4',
          div className:'panel panel-default',
            div className:'panel-heading',
              h3 className:'panel-title', "Subs"
            div className:'panel-body', "Panel content"
