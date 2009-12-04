class AddPolymorphToTranslations < ActiveRecord::Migration
  def self.up
    remove_column :translations, :question_id
    
    add_column :translations, :content_id, :integer, :null => false
    add_column :translations, :content_type, :string, :null => false

    add_index :translations, :content_id
    add_index :translations, :content_type
  end

  def self.down
    remove_column :translations, :content_id
    remove_column :translations, :content_type
  end
end
