class ChangeMuaAccount < ActiveRecord::Migration
  def change
      add_reference :mua_accounts, :lien, index: true, foreign_key: true
  end
end
