class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :prompts, :prompt_id_ext
    add_index :responses, :vote_id_ext
  end

  def self.down
    remove_index :prompts, :prompt_id_ext
    remove_index :responses, :vote_id_ext
  end
end
