class CreateLlcs < ActiveRecord::Migration
  def change
    create_table :llcs do |t|

      t.timestamps null: false
    end
  end
end
