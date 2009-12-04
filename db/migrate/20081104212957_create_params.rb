class CreateParams < ActiveRecord::Migration
  def self.up
    create_table :params do |t|
      t.string :name, :null => false
      t.string :value, :null => false
      t.timestamps
    end

    add_index :params, :name
  end

  def self.down
    drop_table :params
  end
end
