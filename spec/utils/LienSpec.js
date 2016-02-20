describe('Lien', function() {

  it('should be able to build a lien', function() {
    lien = FactoryPanda.build('lien')
    expect(lien).toBeTruthy()
  })

  describe('flat rate calculation', function() {
    it('should be 2% if < $5,000', function() {
      options = {cert_fv: 1000}
      lien = FactoryPanda.build('lien', [], options)
      expect(lien.flat_rate()).toBe(20)
    })
    it('should be 4% if  $5,000 < x < $10,000', function() {
      options = {cert_fv: 8000}
      lien = FactoryPanda.build('lien', [], options)
      expect(lien.flat_rate()).toBe(40 * 8)
    })
    it('should be 6% if < $10,000', function() {
      options = {cert_fv: 10000}
      lien = FactoryPanda.build('lien', [], options)
      expect(lien.flat_rate()).toBe(60 * 10)
    })
  })
})
