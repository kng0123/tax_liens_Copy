var Parse = require('parse')

class Township extends Parse.Object {
  constructor() {
    super('Township');
  }

  static findOrCreate(township) {
    var query = new Parse.Query('Township');
    query.equalTo('township', township);
    return query.find().then(function(townships) {
      if( townships.length ) {
        return townships[0]
      } else {
        var ts = new Township()
        ts.set("township", township);
        return ts.save()
      }
    })
  }
}

Parse.Object.registerSubclass('Township', Township);

module.exports = Township
