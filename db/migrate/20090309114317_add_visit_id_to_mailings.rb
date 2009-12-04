class AddVisitIdToMailings < ActiveRecord::Migration
  def self.up
    add_column :mailings, :visit_id, :integer, :null => false
  end

  def self.down
    remove_column :mailings, :visit_id
  end
end
