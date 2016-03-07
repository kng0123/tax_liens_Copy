'use strict';
let LienSub = App.Models.LienSub
FactoryPanda.define('lien_sub', LienSub, class LienSubFactory extends FactoryDefinition {
  static build(instance, traits=[], options={}) {
    instance.set("check_date", moment().subtract(options.past_days || 0, 'days').toDate());
    instance.set("date", moment().subtract(options.past_days || 0, 'days').toDate());
    instance.set("deposit_date", undefined);
    instance.set("check_number", undefined);
    instance.set("amount", options.amount || 100);
    instance.set("type", 'tax');
    instance.set("dif", undefined);
    instance.set("check_principal", undefined);
    instance.set("check_interest", undefined);

    super.build(instance, traits, options);
    return instance
  }

});
