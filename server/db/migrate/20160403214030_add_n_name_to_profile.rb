class AddNNameToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :name, :string
  end
end
