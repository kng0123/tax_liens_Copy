'use strict';

describe('Lien', function() {

  it('should be able to build a lien', function() {
    var lien = Factory.build('lien');
    expect(lien).toBeTruthy();
  })

  describe('flat rate calculation', function() {
    it('should be 2% if < $5,000', function() {
      var options = {cert_fv: 1000};
      var lien = Factory.build('lien', [], options);
      expect(lien.flat_rate()).toBe(20);
    })
    it('should be 4% if  $5,000 < x < $10,000', function() {
      var options = {cert_fv: 800000};
      var lien = Factory.build('lien', [], options);
      expect(lien.flat_rate()).toBe(4000 * 8);
    })
    it('should be 6% if < $10,000', function() {
      var options = {cert_fv: 1000000};
      var lien = Factory.build('lien', [], options);
      expect(lien.flat_rate()).toBe(6000 * 10);
    })
    it('should be 0 If “Redeemed within 10 days” is true, = $0', function() {
      var options = {cert_fv: 10000, redeem_in_10: true};
      var lien = Factory.build('lien', [], options);
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
      var lien = Factory.build('lien', [], options);
      expect(lien.cert_interest()).toBe(interest);
    })
  })

  describe('Totals', function() {
    let lien = undefined;
    beforeEach(function() {
      var options = {
        winning_bid: 10,
        cert_fv: 200,
        premium: 1000,
        recording_fee: 300,
        search_fee: 50,
        redemption_date: moment().add(365, 'days').toDate(),
        sale_date: moment().toDate(),
        sub_amounts: [500, 2000, 1000]
      };
      lien = Factory.build('lien', ['with_subs'], options);
    })
    describe('Total cash out', function() {
      //TODO: Where are legal fees?
      it('should be FV + Premium + Recording Fee + ALL Subs Paid + Legal Fees', function() {
        expect(lien.total_cash_out()).toBe(5000);
      })
    })

    describe('Total interest due', function() {
      it('should be Flat Rate + Certificate Interest + Sub Interest + YEP Interest', function() {
        expect(lien.total_interest_due()).toBe(304)
      })
    })
    describe('Expected Amount', function() {
      it('should be Total Cash Out + Total Interest Due + Search Fee', function() {
        expect(lien.expected_amount()).toBe(5354)
      })
    })
    describe('Difference', function() {
      it('should be Expected Amount – Redemption Amount', function() {
        expect(lien.diff()).toBe(5354)
      })
    })
  })

  describe('total outstanding balance per lien as of a certain date', function() {
    it('should be written', function() {
      // expect(false).toBeTruthy()
    })
  })


})
