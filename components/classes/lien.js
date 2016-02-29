var accounting = require('accounting')
var LienCheck = require('./LienCheck')
var LienSub = require('./LienSub')
var LienNote = require('./LienNote')
var LienOwner = require('./LienOwner')
var Parse = require('parse')

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
    var cert_fv = this.get('cert_fv') || 0
    var premium = this.get('premium') || 0
    var recording_fee = this.get('recording_fee') || 0
    var subs_paid = this.get('subs').reduce((total, sub)=>{
      return total+sub.amount()
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
    if (!this.get('redemption_date')) {
      return 0
    }
    return this.expected_amount() -this.total_check()
  }

  sub_interest() {
    return this.get('subs').reduce((total, sub) => {
      return total + sub.interest()
    }, 0)
  }

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
      return 0
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
      if(curr.get('void')) {
        return 0
      }
      var sub_date = moment(curr.get('date'))
      if(sub_date < base_date) {
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
    //TODO: Lien defaults
    if(!lien.get('search_fee')) {
      lien.set('search_fee', 12)
    }
    lien.set('township', data.general.township)
    lien.set('2013_yep', 0)
    lien.set('yep_int', 0)
    // lien.subs = data.subs.map( (sub) => LienSub.init_from_json(lien, sub))
    // lien.checks = data.checks.map( (check) => LienCheck.init_from_json(lien, check))
    // lien.annotations = data.annotations.map( (note) => LienNote.init_from_json(lien, note))
    return lien
  }

  static save_json(lien, object) {
    lien.set('subs', object.subs.map( (sub) => LienSub.init_from_json(lien, sub)) )
    lien.set('owners', object.owners.map( (owner) => LienOwner.init_from_json(lien, owner)) )
    lien.set('checks', object.checks.map( (check) => LienCheck.init_from_json(lien, check)) )
    lien.set('annotations', object.annotations.map( (note) => LienNote.init_from_json(lien, note)) )
    return lien
  }

  add_check(check) {
    var checks = this.get('checks')
    checks.push(check)
    this.set('checks', checks)
  }
}




// After specifying the Lien subclass...
Parse.Object.registerSubclass('Lien', Lien);

module.exports = Lien
