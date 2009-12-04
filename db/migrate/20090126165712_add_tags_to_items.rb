class AddTagsToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :tags, :string
  end

  def self.down
    remove_column :items, :tags
  end
end
