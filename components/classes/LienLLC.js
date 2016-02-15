var accounting = require('accounting')

class LienLLC extends Parse.Object {
  constructor() {
    super('LienLLC');
  }

  static init_from_json(lien, data) {
    var llc = new LienLLC()
    llc.set("lien", lien);

    data = JSON.parse(JSON.stringify(data), ( (k,v) => {
        var date_types = ['check_date', 'deposit_date']
        if(date_types.includes(k)) {
          return new Date(data[k])
        } else {
           return v
        }
      })
    )

    Object.keys(data).map ( (key)=>
      llc.set(key,data[key])
    )

    return llc
  }
}

Parse.Object.registerSubclass('LienLLC', LienLLC);

module.exports = LienLLC
