var Backbone = require('backbone');
var RelationalModel = require('backbone-relational')

class Lien extends Backbone.RelationalModel {
  relations() {
    return [{
      type: Backbone.HasMany,
      key: 'subsequents',
      relatedModel: Subsequent,
      collectionType: SubsequentCollection
    }]
  }
  constructor(options) {
    super(options);
  }
  // Note the omission of the 'function' keyword— it is entirely optional in
  // ES6.
  url() {
    return '/liens/'+this.get('id')
  }

  // *Define some default attributes for the todo.*
  defaults() {
    return {
    };
  }

  save() {
    super.save({},{
      success:(i, data) => {
        this.set(data)
      }, error: function() {
      }
    })
  }
}

class LienCollection extends Backbone.Collection{
  // #### Constructors and Super Constructors
  // Specifying a `constructor` lets us define the class constructor. Use of the
  // `super` keyword in your constructor lets you call the constructor of a parent
  // class so that it can inherit all of its properties.
  constructor(options) {
    super(options);

    // *Hold a reference to this collection's model.*
    this.model = Lien;
  }
  url() {
    return '/liens'
  }
}

class Subsequent extends Backbone.RelationalModel {
  relations() {
    return [{
      type: Backbone.HasOne,
			key: 'lien_id',
			relatedModel: Lien
  	}]
  }
  constructor(options) { super(options); }
  url() { return '/subsequents/'+this.get('id')}
  defaults() { return {}; }

  save() {
    super.save({},{
      success:(i, data) => {
        this.set(data)
      }, error: function() {
      }
    })
  }
}

class SubsequentCollection extends Backbone.Collection{
  constructor(options) {
    super(options);
    this.model = Subsequent;
  }
}

class Township extends Backbone.RelationalModel {
  constructor(options) { super(options); }
  url() { return '/townships/'+this.get('id')}
  defaults() { return {}; }
}
class TownshipCollection extends Backbone.Collection{
  constructor(options) {
    super(options);
    this.model = Township;
  }
  url() { return '/townships' }
}

module.exports = function(b) {
  b.Models.Lien = Lien
  b.Collections.LienCollection = LienCollection
  b.Collections.TownshipCollection = TownshipCollection
}
