var accounting = require('accounting')

class LienCheck extends Parse.Object {
  constructor() {
    super('LienCheck');
  }

  expected_amount() {
    var type = this.get('type')
    //TODO Sub Payment Only
    //TODO MISC
    //TODO SOLD
    if(type == 'Combined') {
      return this.get('lien').expected_amount()
    } else if (type == 'Cert Only') {
      return this.get('lien').expected_amount() - this.get('lien').get('premium')
    } else if (type == 'Premium Only') {
      return this.get('lien').get('premium')
    }
    return 0
  }

  static init_from_json(lien, data) {
    var check = new LienCheck()
    check.set("lien", lien);

    data = JSON.parse(JSON.stringify(data), ( (k,v) => {
        var number_types = ['check_amount']
        var date_types = ['check_date', 'deposit_date']
        var calc_types = ['check_interest', 'check_principal', 'dif']
        if(number_types.includes(k)){
          return accounting.unformat(data[k], ".")
        }else if(date_types.includes(k)) {
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

    return check
  }
}

Parse.Object.registerSubclass('LienCheck', LienCheck);

module.exports = LienCheck
