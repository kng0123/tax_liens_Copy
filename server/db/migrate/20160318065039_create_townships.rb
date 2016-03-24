class CreateTownships < ActiveRecord::Migration
  def change
    create_table :townships do |t|

      t.timestamps null: false
    end
  end
end
