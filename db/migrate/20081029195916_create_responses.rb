class CreateResponses < ActiveRecord::Migration
  def self.up
    create_table :responses do |t|
      t.integer :visit_id, :null => false
      t.integer :prompt_id, :null => false
      t.integer :vote_id_ext, :null => false
      t.integer :response_time, :null => false
      t.string :ip_country_code
      t.timestamps
    end

    create_table :items_responses, :id => false do |t|
      t.integer :item_id, :null => false
      t.integer :response_id, :null => false
    end

    add_index :responses, :ip_country_code
    add_index :responses, :visit_id
    add_index :responses, :prompt_id

    add_index :items_responses, :item_id
    add_index :items_responses, :response_id
  end

  def self.down
    drop_table :responses
    drop_table :items_responses
  end
end
