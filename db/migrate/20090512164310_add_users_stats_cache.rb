class AddUsersStatsCache < ActiveRecord::Migration
  def self.up
    add_column :users, :items_count, :integer
    add_column :users, :items_responses_count, :integer
    add_column :users, :responses_rank, :integer
    add_column :users, :responses_count, :integer
    add_column :users, :cached_at, :datetime
  end

  def self.down
    remove_column :users, :items_count
    remove_column :users, :items_responses_count
    remove_column :users, :responses_rank
    remove_column :users, :responses_count
    remove_column :users, :cached_at
  end
end
