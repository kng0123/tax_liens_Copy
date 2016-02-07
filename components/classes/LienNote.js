class LienNote extends Parse.Object {
  constructor() {
    super('LienNote');
  }
  static init_from_json(lien, data) {
    var note = new LienNote()
    note.set("lien", lien);
    return note
  }
}


Parse.Object.registerSubclass('LienNote', LienNote);

module.exports = LienNote
