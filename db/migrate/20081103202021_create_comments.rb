class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :item_id, :null => false
      t.integer :visit_id, :null => false
      t.text :content, :null => false
      t.boolean :active, :default => true
      t.timestamps
    end

    add_index :comments, :item_id
    add_index :comments, :visit_id
  end

  def self.down
    drop_table :comments
  end
end
