class CreateFlags < ActiveRecord::Migration
  def self.up
    create_table :flags do |t|
      t.integer :item_id
      t.integer :comment_id
      t.integer :visit_id, :null => false
      t.integer :flag_type_id, :null => false
      t.text :content
      t.boolean :active, :default => true
      t.timestamps
    end

    add_index :flags, :item_id
    add_index :flags, :comment_id
    add_index :flags, :visit_id
    add_index :flags, :flag_type_id
  end

  def self.down
    drop_table :flags
  end
end
