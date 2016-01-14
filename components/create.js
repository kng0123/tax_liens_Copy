Lien = Parse.Object.extend("Lien");

lien = new Lien();

lien.set("unique_id", '14AtlanticCity1');
lien.set("county", 'Atlantic City');
lien.set("year", '2014');
lien.set("llc", 'TTLBL');
lien.set("block_lot", '22-2-');
lien.set("block", '22');
lien.set("lot", '2');
lien.set("qualifier", '');
lien.set("adv_number", '102');
lien.set("mua_account_number", '02 00022-0000-00002');
lien.set("cert_number", '14-00025');

lien.set("lien_type", 'Apartments (generic)');
lien.set("list_item", 'T');
lien.set("current_owner", '3536 PACIFIC AVE CORP');
lien.set("longitude", '-74.45208');
lien.set("latitude", '39.35021');
lien.set("assessed_value", 670000);
lien.set("tax_amount", 2243160);
lien.set("status", 'Redeemed');
lien.set("address", '3536 PACIFIC AVE');
lien.set("cert_fv", 2382715);
lien.set("winning_bid", 0);
lien.set("premium", 1000000);

lien.set("total_paid", 3382715);
lien.set("sale_date", '12/11/2014, 12:00:00 AM');
lien.set("recording_fee", 4000);
lien.set("recording_date", '3/2/2015, 12:00:00 AM');
lien.set("search_fee", 1200);

lien.set("flat_rate", 142963);
lien.set("cert_int", 0);


lien.save(null, {
  success: function(gameScore) {
    // Execute any logic that should take place after the object is saved.
    alert('New object created with objectId: ' + gameScore.id);
  },
  error: function(gameScore, error) {
    // Execute any logic that should take place if the save fails.
    // error is a Parse.Error with an error code and message.
    alert('Failed to create new object, with error code: ' + error.message);
  }
});
