var accounting = require('accounting')

class LienSub extends Parse.Object {
  constructor() {
    super('LienSub');
  }

  interest() {
    var lien = this.get('lien')
    var sub_total_before = lien.total_subs_before_sub(this)
    var cert_fv = lien.get('cert_fv')
    var sub_amount = this.get('amount')

    var interest = 0
    var days = lien.redeem_days(this.get('sub_date'))


    if (sub_total_before + cert_fv >= 1500) {
      interest = this.get('amount') * (days/365) * 0.18
    } else {
      if (sub_total_before + cert_fv + sub_amount <= 1500) {
        interest = this.get('amount') * (days/365) * 0.08
      } else {
        var low_interest = 1500 - (cert_fv + sub_amount)
        var high_interst = sub_amount - low_interest

        interest = low_interest * (days/365) * 0.08 + high_interst * (days/365) * 0.18
      }
    }

    return interest
  }
  static init_from_json(lien, data) {
    var sub = new LienSub()
    sub.set("lien", lien);

    data = JSON.parse(JSON.stringify(data), ( (k,v) => {
        var number_types = ['check_amount']
        var date_types = ['sub_date', 'check_date']
        var calc_types = ['interest']
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
      sub.set(key,data[key])
    )

    return sub
  }
}

Parse.Object.registerSubclass('LienSub', LienSub);

module.exports = LienSub
