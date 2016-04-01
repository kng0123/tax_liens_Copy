class AddLienToNote < ActiveRecord::Migration
  def change
    add_reference :notes, :lien, index: true, foreign_key: true
    add_reference :notes, :profile, index: true, foreign_key: true
    change_table :notes do |t|
      t.integer :external_id
      t.string :note_type
    end
  end
end
