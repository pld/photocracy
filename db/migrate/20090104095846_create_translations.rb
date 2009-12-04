class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.integer :question_id, :null => false
      t.string :value, :null => false
      t.string :locale, :null => false

      t.timestamps
    end

    add_index :translations, :question_id
    add_index :translations, :locale
  end

  def self.down
    drop_table :translations
  end
end
