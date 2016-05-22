'use strict';

describe('LienSub', function() {

  it('should be able to build a lien sub', function() {
    var lien_sub = Factory.build('lien_sub')
    expect(lien_sub).toBeTruthy()
  })

  describe('Sub Interest', function() {
    describe('When cumulative total of FV + prior subs is...', function() {
      let lien = undefined;
      beforeEach(function() {
        var options = {
          winning_bid: 1000,
          cert_fv: 10000,
          redemption_date: moment().add(365, 'days').toDate(),
          sale_date: moment().toDate(),
          sub_amounts: [50000, 200000, 100000]
        };

        lien = Factory.build('lien', ['with_subs'], options)
      })
      it('should be 8% if Amount of sub (or portion of sub) * (Redemption date – Sale date)/365 < $1500', function() {
        expect(lien.get('subs')[0].interest()).toBe(4000)
      })
      it('should be a mix if it straddles', function() {
        //The cert_fv is 100 so its a 900/1100 split
        expect(lien.get('subs')[1].interest()).toBe(27000)
      })
      it('should be 18% if Amount of sub (or portion of sub) * (Redemption date – Sale date)/365 > $1500', function() {
        expect(lien.get('subs')[2].interest()).toBe(18000)
      })
    })
  })

  //Subs are batched and sent to townships
  //Townships write in the amounts and send it back to be copied
  describe('Batch operations', function() {
    describe('Generate report to send to townships', function() {
      //Remove where sub status is redeemed or status is none
      it('should be written', function() {
        // expect(false).toBeTruthy()
      })
    })
    describe('Export to Excel of subs', function() {
      it('should be written', function() {
        // expect(false).toBeTruthy()
      })
    })
    //This is to void checks that we recieve
    describe('Remove subs by batch', function() {
      it('should be written', function() {
        // expect(false).toBeTruthy()
      })
    })
  })
})
