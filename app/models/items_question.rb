class ItemsQuestion < ActiveRecord::Base
  belongs_to :item
  belongs_to :question

  validates_presence_of :item_id
  validates_presence_of :question_id

  validates_numericality_of :position, :allow_nil => true, :only_integer => true
  validates_numericality_of :losses, :only_integer => true
  validates_numericality_of :wins, :only_integer => true
  validates_numericality_of :ratings, :only_integer => true
end
