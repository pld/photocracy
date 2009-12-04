class AddJointIndexes2 < ActiveRecord::Migration
  def self.up
    add_index :items_prompts, [:item_id, :prompt_id]
  end

  def self.down
    remove_index :items_prompts, [:item_id, :prompt_id]
  end
end
