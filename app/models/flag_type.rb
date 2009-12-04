class FlagType < ActiveRecord::Base
  has_many :flags

  validates_presence_of :name
end
