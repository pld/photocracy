class CreateFlickrs < ActiveRecord::Migration
  def self.up
    create_table :flickrs do |t|
      t.integer :item_id, :null => false
      t.string :title
      t.integer :num_comments
      t.integer :license_id
      t.string :posted
      t.string :lastupdate
      t.string :taken
      t.text :tags
      t.string :description
      t.string :username
      t.integer :photo_id
      t.string :longitude
      t.string :latitude
      t.integer :accuracy
      t.string :country
      t.string :region
      t.string :place_id
      t.timestamps
    end

    add_index :flickrs, :item_id
  end

  def self.down
    drop_table :flickrs
  end
end
