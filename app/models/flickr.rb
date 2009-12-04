class Flickr < ActiveRecord::Base
  belongs_to :item
  validates_presence_of :item_id
end
