class AddLockToVisits < ActiveRecord::Migration
  def self.up
    add_column :visits, :lock, :boolean, :default => 0
  end

  def self.down
    remove_column :visits, :lock
  end
end
