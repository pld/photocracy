class CreateTrackings < ActiveRecord::Migration
  def self.up
    create_table :trackings do |t|
      t.integer :visit_id, :null => false
      t.string :controller, :null => false
      t.string :action, :null => false
      t.string :parameters
      t.timestamps
    end

    # we want inserts to be cheap
    # add_index :trackings, :visit_id
  end

  def self.down
    drop_table :trackings
  end
end
