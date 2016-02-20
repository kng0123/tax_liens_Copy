describe('Lien', function() {

  it('should be able to build a lien', function() {
    lien = FactoryPanda.build('lien')
    expect(lien).toBeTruthy()
  })
})
