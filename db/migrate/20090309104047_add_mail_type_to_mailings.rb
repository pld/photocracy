class AddMailTypeToMailings < ActiveRecord::Migration
  def self.up
    add_column :mailings, :mail_type, :string
  end

  def self.down
    remove_column :mailings, :mail_type
  end
end
