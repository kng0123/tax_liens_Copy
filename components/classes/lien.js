var uuid = require('uuid')
var accounting = require('accounting')
class Lien extends Parse.Object {
  constructor() {
    // Pass the ClassName to the Parse.Object constructor
    super('Lien');
    // All other initialization
    this.id = uuid()
    this.subs = this.relation("subs");
    this.checks = this.relation("checks");
    this.annotations =  this.relation("annotations");
  }

  hasSuperHumanStrength() {
    return this.get('strength') > 18;
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
          return new Date(info[k])
        }else if(calc_types.includes(k)) {
          return ""
        } else {
           return v
        }
      })
    )

    Object.keys(info).map ( (key)=>
      lien.set(key,info[key])
    )

    data.subs.map( (sub) =>
      lien.subs.add(LienSub.init_from_json(lien, sub))
    )

    data.checks.map( (check) =>
      lien.checks.add( LienCheck.init_from_json(lien,check))
    )

    data.annotations.map( (note) =>
      lien.checks.add( LienNote.init_from_json(lien, note))
    )

    return lien;
  }
}

class LienCheck extends Parse.Object {
  constructor() {
    super('LienCheck');
    this.id = uuid()
  }
  static init_from_json(lien, data) {
    var check = new LienCheck()
    check.set("lien", lien);
    return check
  }
}
class LienSub extends Parse.Object {
  constructor() {
    super('LienSub');
    this.id = uuid()
  }
  static init_from_json(lien, data) {
    var sub = new LienSub()
    sub.set("lien", lien);
    return sub
  }
}
class LienNote extends Parse.Object {
  constructor() {
    super('LienNote');
    this.id = uuid()
  }
  static init_from_json(lien, data) {
    var note = new LienNote()
    note.set("lien", lien);
    return note
  }
}

// After specifying the Lien subclass...
Parse.Object.registerSubclass('Lien', Lien);
Parse.Object.registerSubclass('LienCheck', LienCheck);
Parse.Object.registerSubclass('LienSub', LienSub);
Parse.Object.registerSubclass('LienNote', LienNote);

module.exports = Lien
