class AddFieldsToAll3 < ActiveRecord::Migration
  def change
    change_table :liens do |t|
      t.string :city
      t.string :state
      t.string :zip
      t.boolean :redeem_in_10
    end
  end
end
