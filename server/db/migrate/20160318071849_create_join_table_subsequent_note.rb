class CreateJoinTableSubsequentNote < ActiveRecord::Migration
  def change
    create_join_table :subsequents, :notes do |t|
      # t.index [:subsequent_id, :note_id]
      # t.index [:note_id, :subsequent_id]
    end
  end
end
