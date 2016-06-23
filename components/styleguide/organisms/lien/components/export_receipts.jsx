import Molecules from '../../../molecules'

const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const Paper = require('material-ui/lib/paper');

function format_date(date) {
  if(date) {
    return moment(date).format('M/D/Y')
  } else {
    return ""
  }
}


const ExportReceipts = React.createClass({
  getInitialState: function() {
    return {
    }
  },
  submitForm: function(model) {
    // let action = Actions.attempt_sign_in(model)
    // this.props.dispatch(action)
    var liens = this.props.liens
    var from = model.from
    var to = model.to

    window.location.assign("/lien/export_receipts.csv?"+$.param(model));
    this.props.callback()
  },

  styles: {
    paperStyle: {
      width: '100%',
      padding: 20
    },
    switchStyle: {
      marginBottom:16
    },
    submitStyle: {
      marginTop: 32
    },
    linksStyle: {
      marginTop: 10
    }
  },

  updateFormState: function(model) {
    if(model.eventPhase) {
      return
    }
    this.setState({model: model})
  },

  render: function () {
    let {paperStyle, switchStyle, submitStyle, linksStyle } = this.styles;
    let {div, span, h3, ul, li, fieldset, label} = React.DOM
    let link = React.createFactory( ReactRouter.Link )

    let error = <div></div>
    if( this.props.form['sign_in'] && this.props.form['sign_in'].error ) {
      error = <div className="alert alert-danger" role="alert" style={{marginBottom:0}}>
        <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
        <span className="sr-only">{"Error:"}</span>
        {"Invalid username/password"}
      </div>
      }


    var from = new Date()
    var to = new Date()

    var form_rows = [
      {
        label: 'From',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='from' value={from} required/>
      },
      {
        label: 'To',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='to' value={to} required/>
      }
    ]
    var form_body = form_rows.map( (row, key) => {
        var className="form-group row"
        return (<div className={className} key={key}>
          <label htmlFor="type" className="col-sm-3 form-control-label">{row.label}</label>
          <div className="col-sm-9">
            {row.element}
          </div>
        </div>)
    })

    return (
      <div style={paperStyle}>
        <Formsy.Form onValidSubmit={this.submitForm} onChange={this.updateFormState}>
          {form_body}
          <MUI.RaisedButton key={"end"} label={"Export receipts"} type={"submit"} primary={true} />
        </Formsy.Form>
      </div>
    )
  }
})

var accounting = require('accounting')
var format_money = function(money) {
  var acc_format = {symbol : "", decimal : ".", precision : 2, format: "%s%v"}
  return money/100
}

export default ExportReceipts
