class AddTownshipToLien < ActiveRecord::Migration
  def change
    add_reference :liens, :township, index: true, foreign_key: true
  end
end
