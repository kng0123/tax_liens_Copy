class AddFieldsToNote < ActiveRecord::Migration
  def change
    add_column :notes, :comment, :string
  end
end
