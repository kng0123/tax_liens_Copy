class CreateJoinTableLienMuaAccount < ActiveRecord::Migration
  def change
    create_join_table :liens, :mua_accounts do |t|
      # t.index [:lien_id, :mua_account_id]
      # t.index [:mua_account_id, :lien_id]
    end
  end
end
