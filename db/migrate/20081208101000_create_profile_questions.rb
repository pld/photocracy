class CreateProfileQuestions < ActiveRecord::Migration
  def self.up
    create_table :profile_questions do |t|
      t.integer :profile_id, :null => false
      t.string :name, :null => false
      t.string :value, :null => false
      t.timestamps
    end

    add_index :profile_questions, :profile_id
    add_index :profile_questions, :name
  end

  def self.down
    drop_table :profile_questions
  end
end
