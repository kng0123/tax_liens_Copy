var accounting = require('accounting')
var Parse = require('parse')

class LienCheck extends Parse.Object {
  constructor() {
    super('LienCheck');
  }

  expected_amount() {
    var type = (this.get('type') || "").toLowerCase()
    //TODO Sub Payment Only
    //TODO MISC
    //TODO SOLD
    if(type == 'combined') {
      return this.get('lien').expected_amount()
    } else if (type == 'cert_w_interest') {
      return this.get('lien').expected_amount() - this.get('lien').get('premium')
    } else if (type == 'premium') {
      return this.get('lien').get('premium')
    } else if (type == 'sub_only') {
      return this.get('sub').amount
    }
    return 0
  }

  static code_options() {
    return [
      {label: 'Combined', value:'combined'},
      {label: 'Premium', value:'premium'},
      {label: 'Cert w/ Interest', value:'cert_w_interest'},
      {label: 'Sub Only', value:'sub_only'},
      {label: 'Misc', value:'misc'},
      {label: 'Sold', value:'sold'}
    ]
  }

  static init_from_json(lien, data) {
    var check = new LienCheck()
    check.set("lien", lien);

    data = JSON.parse(JSON.stringify(data), ( (k,v) => {
        var number_types = ['check_amount']
        var date_types = ['check_date', 'deposit_date']
        var calc_types = ['check_interest', 'check_principal', 'dif']
        if(number_types.includes(k)){
          return accounting.unformat(data[k], ".")*100
        }else if(date_types.includes(k)) {
          if(data[k].iso) {
            return new Date(date[k].iso)
          }
          return new Date(data[k])
        }else if(calc_types.includes(k)) {
          return ""
        } else {
           return v
        }
      })
    )

    Object.keys(data).map ( (key)=>
      check.set(key,data[key])
    )
    check.set('sub', data.sub)

    return check
  }
}

Parse.Object.registerSubclass('LienCheck', LienCheck);

module.exports = LienCheck
