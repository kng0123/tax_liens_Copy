var accounting = require('accounting')
var Parse = require('parse')

class LienOwner extends Parse.Object {
  constructor() {
    super('LienOwner');
  }

  static init_from_json(lien, data) {
    var owner = new LienOwner()
    owner.set("lien", lien);

    data = JSON.parse(JSON.stringify(data), ( (k,v) => {
      var date_types = ['start_date', 'check_date']
      if(date_types.includes(k) && data[k] != "") {
        return new Date(data[k])
      } else {
        return v
      }
    }))

    Object.keys(data).map ( (key)=>
      owner.set(key,data[key])
    )

    return owner
  }
}

Parse.Object.registerSubclass('LienOwner', LienOwner);

module.exports = LienOwner
