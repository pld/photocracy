class AddJointIndexes < ActiveRecord::Migration
  def self.up
    add_index :prompts, [:active, :user_id, :question_id]
  end

  def self.down
    remove_index :prompts, [:active, :user_id, :question_id]
  end
end
