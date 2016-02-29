import Molecules from '../../../molecules'

const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const Paper = require('material-ui/lib/paper');

console.log(Molecules);

const CreateReceipt = React.createClass({
  getInitialState: function() {
    return {
      receipt: new App.Models.LienCheck(),
      model: {}
    }
  },
  submitForm: function(model) {
    // let action = Actions.attempt_sign_in(model)
    // this.props.dispatch(action)

    var check = App.Models.LienCheck.init_from_json(this.props.lien, model)
    this.props.lien.add_check(check)
    this.props.lien.save()
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

    var deposit_date = undefined
    if(this.state.receipt.get('deposit_date')) {
      deposit_date = (this.state.receipt.get('deposit_date'))
    }
    var check_date = undefined
    if(this.state.receipt.get('check_date')) {
      check_date = (this.state.receipt.get('check_date'))
    }
    var redeem_date = undefined
    if(this.state.receipt.get('redeem_date')) {
      redeem_date = (this.state.receipt.get('redeem_date'))
    }

    var code_options = App.Models.LienCheck.code_options()
    var sub_options = this.props.lien.get('subs').map( (sub) => {
      return {label: sub.name(), value:sub}
    })

    var form_rows = [
      {
        label: 'Code',
        element: <Styleguide.Molecules.Forms.ReactSelect options={code_options} required name={"type"}/>
      },
        {
          label: 'Sub',
          filter: (function(){ return this.state.model.type != 'sub_only'}).bind(this),
          element: <Styleguide.Molecules.Forms.ReactSelect renderValue={function(sub){if(sub){return sub.name()}}} options={sub_options} required name={"sub"}/>
        },
      {
        label: 'Deposit Date',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='deposit_date' selected={deposit_date} required/>
      },
      {
        label: 'Check Date',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='check_date' selected={check_date} required/>
      },
      {
        label: 'Redeem Date',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='redeem_date' selected={redeem_date}/>
      },
      {
        label: 'Check number',
        element: <FormsyText name='check_number' required hintText="Check number" value=""/>
      },
      {
        label: 'Check amount',
        element: <FormsyText name='check_amount' required hintText="Check amount" value=""/>
      }
    ]
    var form_body = form_rows.map( (row, key) => {
        var className="form-group row"
        if(row.filter && row.filter()) {
          return
        }
        return (<div className={className} key={key}>
          <label htmlFor="type" className="col-sm-3 form-control-label">{row.label}</label>
          <div className="col-sm-9">
            {row.element}
          </div>
        </div>)
    }).filter(function(item){return item})

    return (
      <div style={paperStyle}>
        <Formsy.Form onValidSubmit={this.submitForm} onChange={this.updateFormState}>
          {form_body}
          <MUI.RaisedButton key={"end"} label={"Create receipt"} type={"submit"} primary={true} />
        </Formsy.Form>
      </div>
    )
  }
})

export default CreateReceipt
