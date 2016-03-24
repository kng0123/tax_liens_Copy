class AddFieldsToAll2 < ActiveRecord::Migration
  def change
    change_table :liens do |t|
      t.string :cert_number
      t.string :address
      t.integer :premium
      t.integer :recording_fee
      t.date :recording_date
      t.integer :flat_rate
      t.integer :cert_int
      t.integer :yep_2013
      t.string :picture
      t.date :redemption_date
      t.integer :redemption_amount

    end
  end
end
