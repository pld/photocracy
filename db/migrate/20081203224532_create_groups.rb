class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.string :code
      t.timestamps
    end

    create_table :groups_questions, :id => false do |t|
      t.integer :group_id, :null => false
      t.integer :question_id, :null => false
    end

    add_index :groups, :code
    add_index :groups_questions, :group_id
    add_index :groups_questions, :question_id
  end

  def self.down
    drop_table :groups
    drop_table :groups_questions
  end
end
