var Backbone = require('backbone');
var RelationalModel = require('backbone-relational')

class Lien extends Backbone.RelationalModel {
  constructor(options) {
    super(options);
    this.relations = [{
  		type: Backbone.HasMany,
  		key: 'animals',
  		relatedModel: 'Animal',
  		collectionType: 'AnimalCollection',
  		reverseRelation: {
  			key: 'livesIn',
  			includeInJSON: 'id'
  		}
  	}]
  }
  // Note the omission of the 'function' keyword— it is entirely optional in
  // ES6.
  url() {
    return '/liens/'+this.get('id')
    )
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

module.exports = Lien
