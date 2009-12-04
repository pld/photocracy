class CreateMailings < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      t.integer :user_id, :null => false
      t.integer :item_id
      t.string :name, :null => false
      t.string :email, :null => false
      t.text :message, :null => false
      t.boolean :sent, :default => false
      t.timestamps
    end

    add_index :mailings, :user_id
  end

  def self.down
    drop_table :mailings
  end
end
