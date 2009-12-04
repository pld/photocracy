class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :visit_id, :null => false
      t.integer :attachment_id
      t.integer :item_id_ext, :null => false
      t.string :description
      t.string :attribution
      t.string :external_link
      t.boolean :active, :default => false
      t.timestamps
    end

    add_index :items, :attachment_id
    add_index :items, :item_id_ext
  end

  def self.down
    drop_table :items
  end
end
