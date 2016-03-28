class AddSubsequentBatchToSubsequentNew < ActiveRecord::Migration
  def change
    add_reference :subsequents, :subsequent_batch, index: true, foreign_key: true
    add_reference :subsequent_batches, :township, index: true, foreign_key: true
  end
end
