class CreateJoinTableLienLlc < ActiveRecord::Migration
  def change
    create_join_table :liens, :llcs do |t|
      # t.index [:lien_id, :llc_id]
      # t.index [:llc_id, :lien_id]
    end
  end
end
