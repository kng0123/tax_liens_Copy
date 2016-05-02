class ModifyOverrideCol < ActiveRecord::Migration
  def change
    change_column :receipts, :is_principal_override, :boolean
    add_column :receipts, :is_principal_paid_override, :boolean
    add_column :receipts, :paid_principal, :integer
  end
end
