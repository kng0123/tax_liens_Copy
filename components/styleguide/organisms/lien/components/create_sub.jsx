import Molecules from '../../../molecules'

const FMUI = require('formsy-material-ui');
const { FormsyCheckbox, FormsyDate, FormsyRadio, FormsyRadioGroup, FormsySelect, FormsyText, FormsyTime, FormsyToggle } = FMUI;
const RaisedButton = require('material-ui/lib/raised-button');
const Paper = require('material-ui/lib/paper');

const CreateSub = React.createClass({
  getInitialState: function() {
    return {
      receipt: new BackboneApp.Models.Subsequent(),
      model: {}
    }
  },
  submitForm: function(model) {
    // let action = Actions.attempt_sign_in(model)
    // this.props.dispatch(action)
    var data = {
      type: model.sub_type,
      sub_date: moment(model.sub_date),
      amount: model.amount,
      lien_id: this.props.lien.get('id'),
      note: model.note
    }
    //TODO: Create sub
    var lien = this.props.lien;
    var new_sub = new BackboneApp.Models.Subsequent(data)
    var res = new_sub.save()
    var self = this
    res.success(function() {
      self.props.callback()
    })
    res.error(function() {
      lien.get('subsequents').remove(new_sub);
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

    var sub_date  = moment().format('MM/DD/YYYY')
    var code_options = BackboneApp.Models.Subsequent.code_options()

    var form_rows = [
      {
        label: 'Type',
        element: <Styleguide.Molecules.Forms.ReactSelect options={code_options} required name={"sub_type"}/>
      },
      {
        label: 'Sub Date',
        element: <Styleguide.Molecules.Forms.DatePicker placeholderText={"Select"} width={'150px'} name='sub_date' value={sub_date} required/>
      },
      {
        label: 'Sub amount',
        element: <FormsyText name="amount" required hintText="Sub amount" value=""/>
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
        <Formsy.Form onValidSubmit={this.submitForm} onChange={this.updateFormState}  autoComplete="off">
        <div>
          <div style={{width:'45%', float:'left'}}>
            {form_body}
          </div>
          <div style={{width:'45%', float:'right'}}>
            <div className="form-group row">
              <label htmlFor="type" className="col-sm-3 form-control-label">Note</label>
              <div className="col-sm-9">
                <Styleguide.Molecules.Forms.TextArea name="note" rows={5} value=""/>
              </div>
            </div>
          </div>
        </div>
        <div style={{clear:'both'}}>
          <MUI.RaisedButton key={"end"} label={"Create sub"} type={"submit"} primary={true} />
        </div>
        </Formsy.Form>
      </div>
    )
  }
})

export default CreateSub
