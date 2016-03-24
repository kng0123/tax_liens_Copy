class CreateMuaAccounts < ActiveRecord::Migration
  def change
    create_table :mua_accounts do |t|

      t.timestamps null: false
    end
  end
end
