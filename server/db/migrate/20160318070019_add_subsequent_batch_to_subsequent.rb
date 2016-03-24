class AddSubsequentBatchToSubsequent < ActiveRecord::Migration
  def change
    add_reference :subsequents, :subsequent, index: true, foreign_key: true
  end
end
