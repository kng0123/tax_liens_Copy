'use strict';
let Lien = App.Models.Lien
FactoryPanda.define('lien', Lien, class UserFactory extends FactoryDefinition {
  static build(instance, traits=[], options={}) {
    instance.set("unique_id", '14AtlanticCity1');
    instance.set("county", 'Atlantic City');
    instance.set("year", '2014');
    instance.set("llc", 'TTLBL');
    instance.set("block_lot", '22-2-');
    instance.set("block", '22');
    instance.set("lot", '2');
    instance.set("qualifier", '');
    instance.set("adv_number", '102');
    instance.set("mua_account_number", '02 00022-0000-00002');
    instance.set("cert_number", '14-00025');

    instance.set("lien_type", 'Apartments (generic)');
    instance.set("list_item", 'T');
    instance.set("current_owner", '3536 PACIFIC AVE CORP');
    instance.set("longitude", '-74.45208');
    instance.set("latitude", '39.35021');
    instance.set("assessed_value", 670000);
    instance.set("tax_amount", 2243160);
    instance.set("status", 'Redeemed');
    instance.set("address", '3536 PACIFIC AVE');
    instance.set("cert_fv", options.cert_fv || 2382715);
    instance.set("winning_bid", 0);
    instance.set("premium", 1000000);

    instance.set("total_paid", 3382715);
    instance.set("sale_date", '12/11/2014, 12:00:00 AM');
    instance.set("recording_fee", 4000);
    instance.set("recording_date", '3/2/2015, 12:00:00 AM');
    instance.set("search_fee", 1200);

    instance.set("flat_rate", 142963);
    instance.set("cert_int", 0);
    super.build(instance, traits, options);
    return instance
  }

});
