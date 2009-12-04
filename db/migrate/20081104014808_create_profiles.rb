class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.integer :user_id, :null => false
      t.string :locale
      t.string :country
      t.datetime :date_of_birth
      t.timestamps
    end

    add_index :profiles, :user_id
  end

  def self.down
    drop_table :profiles
  end
end
