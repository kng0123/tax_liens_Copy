import Molecules from '../../../molecules'

var accounting = require('accounting')
const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const Paper = require('material-ui/lib/paper');

const EditSub = React.createClass({
  getInitialState: function() {
    return {
      sub: new BackboneApp.Models.Subsequent(),
      model: {}
    }
  },
  submitForm: function(model) {
    var sub = this.props.sub
    var callback = this.props.callback
    debugger
    Object.keys(model).map(function(key) {
      if(key == 'amount') {
         return sub.set(key,Math.round(accounting.unformat(model.amount) * 100))
      } else {
        return sub.set(key, model[key])
      }
    })
    return sub.save().then(function(){
      callback()
    }).fail(function() {
    })

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

  render: function () {
    let {paperStyle, switchStyle, submitStyle, linksStyle } = this.styles;
    let {div, span, h3, ul, li, fieldset, label} = React.DOM
    let link = React.createFactory( ReactRouter.Link )

    let error = <div></div>


    let sub = this.props.sub
    var sub_amount = accounting.formatMoney(sub.amount()/100, {symbol : "$", decimal : ".", precision : 2, format: "%s%v"})
    var sub_date  = sub.get('sub_date')
    var code_options = BackboneApp.Models.Subsequent.code_options()
    var note = sub.get('text_pad')

    var form_rows = [
      {
        label: 'Type',
        element: <Styleguide.Molecules.Forms.ReactSelect value={sub.get('sub_type')} options={code_options} required name={"sub_type"}/>
      },
      {
        label: 'Sub Date',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='sub_date' value={sub_date} required/>
      },
      {
        label: 'Sub amount',
        element: <FormsyText name="amount" required hintText="Sub amount" value={sub_amount}/>
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
        <Formsy.Form onValidSubmit={this.submitForm} onChange={this.updateFormState} autoComplete="off">
        <div>
          <div style={{width:'45%', float:'left'}}>
            {form_body}
          </div>
          <div style={{width:'45%', float:'right'}}>
            <div className="form-group row">
              <label htmlFor="type" className="col-sm-3 form-control-label">Note</label>
              <div className="col-sm-9">
                <Styleguide.Molecules.Forms.TextArea name="text_pad" rows={5} value={note}/>
              </div>
            </div>
          </div>
        </div>
        <div style={{clear:'both'}}>
          <MUI.RaisedButton key={"end"} label={"Save sub"} type={"submit"} primary={true} />
          <MUI.RaisedButton onTouchTap={this.props.callback} label={"Close"} type={"button"} />
        </div>
        </Formsy.Form>
      </div>
    )
  }
})

export default EditSub
