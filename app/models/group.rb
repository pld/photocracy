class Group < ActiveRecord::Base
  include Translatable

  has_and_belongs_to_many :questions
  has_many  :translations, :as => :content

  validates_presence_of :name
end
