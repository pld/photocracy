class AddActiveIndexes < ActiveRecord::Migration
  def self.up
    add_index :responses, :active
    add_index :prompts, :active
  end

  def self.down
    remove_index :responses, :active
    remove_index :prompts, :active
  end
end
