class AddLienToReceipts < ActiveRecord::Migration
  def change
    add_reference :receipts, :lien, index: true, foreign_key: true
  end
end
