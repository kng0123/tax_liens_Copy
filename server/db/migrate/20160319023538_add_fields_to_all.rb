class AddFieldsToAll < ActiveRecord::Migration
  def change
    change_table :mua_accounts do |t|
      t.string :account_number
    end

    change_table :owners do |t|
      t.string :name
    end

    change_table :townships do |t|
      t.string :name
    end

    change_table :llcs do |t|
      t.string :name
    end

    change_table :receipts do |t|
      t.date :check_date
      t.date :deposit_date
      t.date :redeem_date
      t.string :check_number
      t.string :receipt_type
      t.integer :check_amount
      t.boolean :void
    end

    change_table :subsequents do |t|
      t.date :sub_date
      t.string :sub_type
      t.integer :amount
      t.boolean :void
    end

    change_table :subsequent_batches do |t|
      t.date :sub_date
      t.boolean :void
    end

  end
end
