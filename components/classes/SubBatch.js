var Parse = require('parse')

class SubBatch extends Parse.Object {
  constructor() {
    super('SubBatch');
  }

  static init_from_json(json) {
    var batch = new SubBatch()
    batch.set("subs", json.subs);
    batch.set("township", json.township);
    batch.set("sub_date", json.sub_date);
    batch.set('liens', json.liens)

    return batch
  }
}

Parse.Object.registerSubclass('SubBatch', SubBatch);

module.exports = SubBatch
