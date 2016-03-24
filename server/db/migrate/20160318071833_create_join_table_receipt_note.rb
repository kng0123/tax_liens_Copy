class CreateJoinTableReceiptNote < ActiveRecord::Migration
  def change
    create_join_table :receipts, :notes do |t|
      # t.index [:receipt_id, :note_id]
      # t.index [:note_id, :receipt_id]
    end
  end
end
