class AddOverrideToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :is_principal_override, :bool
  end
end
