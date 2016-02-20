'use strict';
let Lien = App.Models.Lien
FactoryPanda.define('lien', Lien, class UserFactory extends FactoryDefinition {
  static build(instance, traits=[], options={}) {
    super.build(instance, traits, options);
    return instance
  }

  static valid(instance) {
    instance.set('valid', true)
  }

  static has_mobile(instance, options={}) {
    var cc = "+1"
    if( options.country_code ) {
      cc = options.country_code
    }
    instance.set('mobile', cc+"numbers")
  }
});
