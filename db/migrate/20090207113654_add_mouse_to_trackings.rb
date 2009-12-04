class AddMouseToTrackings < ActiveRecord::Migration
  def self.up
    add_column :trackings, :mouse, :text
  end

  def self.down
    remove_column :trackings, :mouse
  end
end
