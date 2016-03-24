class CreateJoinTableLienOwner < ActiveRecord::Migration
  def change
    create_join_table :liens, :owners do |t|
      # t.index [:lien_id, :owner_id]
      # t.index [:owner_id, :lien_id]
    end
  end
end
