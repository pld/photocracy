class CreateStats < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.integer :item_id, :null => false
      t.integer :group_id, :default => nil
      t.integer :question_id, :default => nil
      t.integer :ratings, :null => false
      t.integer :wins, :null => false
      t.integer :losses, :null => false
      t.timestamps
    end

    add_index :stats, :item_id
    add_index :stats, :group_id
    add_index :stats, :question_id
  end

  def self.down
    drop_table :stats
  end
end
