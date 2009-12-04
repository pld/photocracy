class AddActiveToResponses < ActiveRecord::Migration
  def self.up
    add_column :responses, :active, :boolean, :default => 1
  end

  def self.down
    remove_column :responses, :active
  end
end
