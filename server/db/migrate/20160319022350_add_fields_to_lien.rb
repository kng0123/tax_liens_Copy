class AddFieldsToLien < ActiveRecord::Migration
  def change
    change_table :liens do |t|
      t.date :sale_date
      t.string :county
      t.string :year
      t.string :block_lot
      t.string :block
      t.string :lot
      t.string :qualifier
      t.string :adv_number
      t.string :lien_type
      t.string :list_item
      t.string :longitude
      t.string :latitude
      t.integer :assessed_value
      t.integer :tax_amount
      t.string :status
      t.integer :cert_fv
      t.decimal :winning_bid, precision: 4
      t.integer :total_paid
      t.integer :total_cash_out
      t.integer :total_interest_due
      t.integer :search_fee
      t.integer :yep_interest


    end
  end
end
