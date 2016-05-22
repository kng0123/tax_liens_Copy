'use strict';
describe('LienCheck', function() {

  it('should be able to build a lien check', function() {
    var lien_check = Factory.build('lien_check')
    expect(lien_check).toBeTruthy()
  })

  it('should be able to add a check to a lien', function(){
    var lien = Factory.build('lien');
    var check = Factory.build('lien_check', [], {lien:lien})
    expect(lien.get('receipts').models.length).toBe(1)
    expect(check.get('lien')).toBeTruthy()
  })

  describe('dif by receipt code', function() {
    it('should be written', function() {
      // expect(false).toBeTruthy()
    })
  })

  describe('Ability to export all receipts by date ranges', function() {
    it('should be written', function() {
      // expect(false).toBeTruthy()
    })
  })
})
