class CreateFlagTypes < ActiveRecord::Migration
  def self.up
    create_table :flag_types do |t|
      t.string :name, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :flag_types
  end
end
