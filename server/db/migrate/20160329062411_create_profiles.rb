class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :cid
      t.date :birthday
      t.string :sex
      t.string :tel
      t.string :address
      t.string :tagline
      t.text :introduction
    end
  end
end
