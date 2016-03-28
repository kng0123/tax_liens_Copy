class CreateJoinTableLienSubsequentBatch < ActiveRecord::Migration
  def change
    create_join_table :lien, :subsequent_batches do |t|
      # t.index [:lien_id, :note_id]
      # t.index [:note_id, :lien_id]
    end
  end
end
