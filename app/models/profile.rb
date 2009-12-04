class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :profile_questions

  validates_presence_of :user_id
end
