'use strict';
describe('LienCheck', function() {

  it('should be able to build a lien check', function() {
    var lien_check = FactoryPanda.build('lien_check')
    expect(lien_check).toBeTruthy()
  })

  it('should be able to add a check to a lien', function(){
    var lien = FactoryPanda.build('lien');
    var check = FactoryPanda.build('lien_check', [], {lien:lien})
    lien.add_check(check)
    expect(lien.get('checks').length).toBe(1)
    expect(check.get('lien')).toBeTruthy()
  })

})
