class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :size
      t.string :content_type
      t.string :filename, :null => false
      t.integer :width
      t.integer :height
      t.integer :parent_id
      t.string :thumbnail
      t.timestamps
    end

    add_index :attachments, :parent_id
  end

  def self.down
    drop_table :attachments
  end
end
