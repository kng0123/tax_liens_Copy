var accounting = require('accounting')
var Parse = require('parse')

class LienSub extends Parse.Object {
  constructor(options) {
    super('LienSub');
    if(options) {
      this.set('sub_date', options.sub_date)
      this.set('type', options.type)
    }
  }

  name() {
    return this.get('type')+" "+this.get('amount')+" "+moment(this.get('sub_date')).format('MM/DD/YYYY')
  }

  amount() {
    if( this.get('void')) {
      return 0
    }
    return this.get('amount')
  }

  interest() {
    var lien = this.get('lien')
    var sub_total_before = lien.total_subs_before_sub(this)
    var cert_fv = lien.get('cert_fv')
    var sub_amount = this.amount()

    var interest = 0
    var days = lien.redeem_days(this.get('sub_date'))

    if (sub_total_before + cert_fv >= 150000) {
      interest = this.amount() * (days/365) * 0.18
    } else {
      if (sub_total_before + cert_fv + sub_amount <= 1500) {
        interest = this.amount() * (days/365) * 0.08
      } else {
        var low_interest = 150000 - (cert_fv + sub_total_before)
        var high_interest = sub_amount - low_interest
        interest = low_interest * (days/365) * 0.08 + high_interest * (days/365) * 0.18
      }
    }

    return interest
  }
  static init_from_json(lien, data) {
    var sub = new LienSub()
    sub.set("lien", lien);

    data = JSON.parse(JSON.stringify(data), ( (k,v) => {
        var number_types = ['check_amount', 'amount']
        var date_types = ['sub_date', 'check_date']
        var calc_types = ['interest']

        if(number_types.includes(k)){
          return accounting.unformat(data[k], ".")*100
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
