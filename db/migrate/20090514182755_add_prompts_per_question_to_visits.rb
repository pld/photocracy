class AddPromptsPerQuestionToVisits < ActiveRecord::Migration
  def self.up
    add_column :visits, :prompts_per_question, :integer
  end

  def self.down
    remove_column :visits, :prompts_per_question, :integer
  end
end
