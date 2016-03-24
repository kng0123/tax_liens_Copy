class CreateSubsequentBatches < ActiveRecord::Migration
  def change
    create_table :subsequent_batches do |t|

      t.timestamps null: false
    end
  end
end
