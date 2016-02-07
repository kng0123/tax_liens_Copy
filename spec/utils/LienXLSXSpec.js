describe('Lien Upload', function() {
  var data;
  var lien_xlsx;

  beforeAll(function(done) {
    $.get('/base/spec/support/files/lien_base64.txt', function(d) {
      data = d
      data = atob(data)
      lien_xlsx = new App.Utils.LienXLSX(data)
      done()
    })
  });
  it('should import 139 liens', function() {
    expect(lien_xlsx.objects.length).toBe(198)
  })

  //TODO: Should validate the data being uploaded...
})
