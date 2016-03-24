class CreateSubsequents < ActiveRecord::Migration
  def change
    create_table :subsequents do |t|

      t.timestamps null: false
    end
  end
end
