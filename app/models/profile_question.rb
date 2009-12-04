class ProfileQuestion < ActiveRecord::Base
  belongs_to :profile

  validates_presence_of :profile_id
  validates_presence_of :name
  validates_presence_of :value
end
