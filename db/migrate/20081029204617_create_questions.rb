class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer :question_id_ext, :null => false
      t.string :name, :null => false
      t.timestamps
    end
  end
  
  def self.down
    drop_table :questions
  end
end
