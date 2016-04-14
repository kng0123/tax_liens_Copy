class AddSubToReceipt < ActiveRecord::Migration
  def change
    add_reference :receipts, :subsequent, index: true, foreign_key: true
    add_column :receipts, :misc_principal, :integer
  end
end
