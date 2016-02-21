'use strict';
describe('Lien', function() {

  it('should be able to build a lien', function() {
    var lien = FactoryPanda.build('lien');
    expect(lien).toBeTruthy();
  })

  describe('flat rate calculation', function() {
    it('should be 2% if < $5,000', function() {
      var options = {cert_fv: 1000};
      var lien = FactoryPanda.build('lien', [], options);
      expect(lien.flat_rate()).toBe(20);
    })
    it('should be 4% if  $5,000 < x < $10,000', function() {
      var options = {cert_fv: 8000};
      var lien = FactoryPanda.build('lien', [], options);
      expect(lien.flat_rate()).toBe(40 * 8);
    })
    it('should be 6% if < $10,000', function() {
      var options = {cert_fv: 10000};
      var lien = FactoryPanda.build('lien', [], options);
      expect(lien.flat_rate()).toBe(60 * 10);
    })
    it('should be 0 If “Redeemed within 10 days” is true, = $0', function() {
      var options = {cert_fv: 10000, redeem_in_10: true};
      var lien = FactoryPanda.build('lien', [], options);
      expect(lien.flat_rate()).toBe(0);
    })
  })

  describe('Certificate Interest Calculation', function() {
    it('should be (Redemption date – Sale date)/365 * Interest Rate * FV', function() {
      var options = {
        winning_bid: 10,
        cert_fv: 10000,
        redemption_date: moment().add(365, 'days').toDate(),
        sale_date: moment().toDate()
      };
      var interest = 1000;
      var lien = FactoryPanda.build('lien', [], options);
      expect(lien.cert_interest()).toBe(interest);
    })
  })
})
