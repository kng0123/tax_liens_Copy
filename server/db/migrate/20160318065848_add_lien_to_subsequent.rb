class AddLienToSubsequent < ActiveRecord::Migration
  def change
    add_reference :subsequents, :lien, index: true, foreign_key: true
  end
end
