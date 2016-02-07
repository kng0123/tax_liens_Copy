var accounting = require('accounting')
var LienCheck = require('./LienCheck')
var LienSub = require('./LienSub')
var LienNote = require('./LienNote')

class Lien extends Parse.Object {
  constructor() {
    // Pass the ClassName to the Parse.Object constructor
    super('Lien');
    // All other initialization
  }

  hasSuperHumanStrength() {
    return this.get('strength') > 18;
  }

  flat_rate() {
    //If redeem within 10 days then 0
    if (this.redeem_in_10()) {
      return 0
    }
    var cert_fv = this.get('cert_fv')
    var rate = 0.06 //If fv >=1000
    if ( cert_fv < 5000) {
      rate = 0.02
    } else if (cert_fv >= 5000 && cert_fv < 10000) {
      rate = 0.04
    }
    return accounting.unformat(cert_fv * rate)
  }

  search_fee() {
    //If redeem within 10 days then 0
    if (this.redeem_in_10()) {
      return 0
    }
    return this.get('search_fee')
  }

  redeem_in_10() {
    return !!this.get('redeem_in_10')
  }

  total_cash_out() {
    var cert_fv = this.get('cert_fv')
    var premium = this.get('premium')
    var recording_fee = this.get('recording_fee')
    var subs_paid = this.get('subs').reduce((total, sub)=>{
      return total+sub.get('amount')
    }, 0)
    return cert_fv+premium+recording_fee+subs_paid
  }
  //TODO: What is YEP
  total_interest_due() {
    return this.flat_rate()  + this.cert_interest() + this.sub_interest()
  }
  expected_amount() {
    return this.total_cash_out()  + this.total_interest_due() + this.get('search_fee')
  }
  total_check() {
    return this.get('checks').reduce((total, check) =>{
      return total + check.get('check_amount')
    }, 0)
  }
  diff() {
    return this.expected_amount() -this.total_check()
  }

  sub_interest() {
    return this.get('subs').reduce((total, sub) => {
      return total + sub.interest()
    }, 0)
  }
  // Flat Rate + Certificate Interest + Sub Interest + YEP Interest


  redeem_days(date) {
    if(!date) {
      date = moment(this.get('sale_date'))
    } else {
      moment(date)
    }

    if (!this.get('redemption_date')) {
      return 0
    }
    var redemption_date = moment(this.get('redemption_date'))
    var duration = moment.duration(redemption_date.diff(date));
    var days = duration.asDays();
    return Math.round(days)
  }

  cert_interest() {
    if (!this.get('redemption_date')) {
      return
    }
    var days = this.redeem_days()

    var interest_rate = this.get('winning_bid')/100

    var int =  (days / 365) * interest_rate * this.get('cert_fv')
    return int
  }

  total_subs_before_sub(sub) {
    var base_date = moment(sub.get('date'))

    var subs = this.get('subs')
    var total = subs.reduce((prev, curr)=>{
      var sub_date = moment(curr.get('date'))
      if(base_date < sub_date) {
        prev = prev + curr.get('amount')
      }
      return prev
    }, 0)
    return total
    //How do we handle tie breakers
  }

  static init_from_json(data) {
    var lien = new Lien(data.general);
    var info = data.general

    info = JSON.parse(JSON.stringify(info), ( (k,v) => {
        var number_types = ['assessed_value', 'tax_amount', 'cert_fv', 'winning_bid', 'premium', 'total_paid', 'recording_fee', 'search_fee', 'flat_rate', 'cert_int']
        var date_types = ['sale_date', 'recording_date', 'redemption_date', ]
        var calc_types = ['redemption_amt', 'total_cash_out', 'total_int_due', 'mz_check']
        if(number_types.includes(k)){
          return accounting.unformat(info[k], ".")
        }else if(date_types.includes(k)) {
          if( !info[k]){
            return undefined
          }else{
            return new Date(info[k])
          }
        }else if(calc_types.includes(k)) {
          return ""
        } else {
           return v
        }
      })
    )
    Object.keys(info).map ( function(key) {
      lien.set(key,info[key])
    })
    lien.subs = data.subs.map( (sub) => LienSub.init_from_json(lien, sub))
    lien.checks = data.checks.map( (check) => LienCheck.init_from_json(lien, check))
    lien.annotations = data.annotations.map( (note) => LienNote.init_from_json(lien, note))
    return lien
  }

  save_json() {
    return this.save().then(function(lien) {
      lien.set('subs', data.subs.map( (sub) => LienSub.init_from_json(lien, sub)) )
      lien.set('checks', data.checks.map( (check) => LienCheck.init_from_json(lien, check)) )
      lien.set('annotations', data.annotations.map( (note) => LienNote.init_from_json(lien, note)) )

      return lien.save();
    }).fail(function(error) {
      lien.error = error
      return lien
    })
  }
}




// After specifying the Lien subclass...
Parse.Object.registerSubclass('Lien', Lien);

module.exports = Lien
