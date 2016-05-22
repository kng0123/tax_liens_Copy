'use strict';
var id = 0
Factory.define('lien', BackboneApp.Models.Lien, class LienFactory extends FactoryDefinition {
  static build(instance, traits=[], options={}) {
    instance.set("id", ++id);
    // instance.set("unique_id", '14AtlanticCity1');
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
    instance.set("winning_bid", options.winning_bid || 0);
    instance.set("premium", options.premium || 1000000);

    instance.set("sale_date", options.sale_date || new Date());
    instance.set("redemption_date", options.redemption_date || new Date());
    instance.set("recording_fee", options.recording_fee || 4000);
    instance.set("recording_date", '3/2/2015, 12:00:00 AM');
    instance.set("search_fee", options.search_fee || 50);

    instance.set("cert_int", options.cert_int || 0);
    instance.set("redeem_in_10", options.redeem_in_10 || false)
    instance.set('subs', [])
    instance.set('checks', [])
    super.build(instance, traits, options);
    return instance
  }

  static with_subs(instance, options) {
    instance.set('subs', options.sub_amounts.map( (amount, key) => {
      var sub_options = {
        amount: amount,
        past_days: options.sub_amounts.length-key
      }
      var sub = Factory.build('lien_sub', [], sub_options)
      sub.set('lien', instance)
      return sub
    }))
  }

});
