class AddAccountTypeToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :account_type, :string
  end
end
