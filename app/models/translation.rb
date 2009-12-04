class Translation < ActiveRecord::Base
  belongs_to :content, :polymorphic => true

  validates_presence_of :locale
  validates_presence_of :content_id
  validates_presence_of :content_type
  validates_presence_of :value
end
