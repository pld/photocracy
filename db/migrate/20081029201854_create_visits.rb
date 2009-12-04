class CreateVisits < ActiveRecord::Migration
  def self.up
    create_table :visits do |t|
      t.integer :user_id
      t.integer :prompt_id
      t.string :locale
      t.string :ip_address, :null => false
      t.string :ip_city
      t.string :ip_latitude
      t.string :ip_longitude
      t.string :ip_country_code
      t.string :ip_country_name
      t.string :ip_dma_code
      t.string :ip_area_code
      t.string :ip_region
      t.string :host
      t.string :user_agent
      t.string :request_uri
      t.string :referrer
      t.timestamps
    end

    add_index :visits, :user_id
  end

  def self.down
    drop_table :visits
  end
end
