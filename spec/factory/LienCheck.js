'use strict';
let id = 0
Factory.define('lien_check', BackboneApp.Models.Receipt, class LienCheckFactory extends FactoryDefinition {
  static build(instance, traits=[], options={}) {
    instance.set("id", ++id)
    instance.set("deposit_date", moment().subtract(options.past_days || 0, 'days').toDate());
    instance.set("type", 'combined');
    instance.set("dif", undefined);
    instance.set("check_number", undefined);
    instance.set("check_amount", options.check_amount || 100);
    instance.set("check_date", moment().subtract(options.past_days || 0, 'days').toDate());
    instance.set("check_principal", undefined);
    instance.set("check_interest", undefined);
    instance.set('lien', options.lien || undefined)
    super.build(instance, traits, options);
    return instance
  }
});
