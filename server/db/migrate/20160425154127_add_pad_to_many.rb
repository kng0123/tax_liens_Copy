class AddPadToMany < ActiveRecord::Migration
  def change
    add_column :receipts, :text_pad, :text
    add_column :liens, :text_pad, :text
    add_column :subsequents, :text_pad, :text
  end
end
