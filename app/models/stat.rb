class Stat < ActiveRecord::Base
  belongs_to :item
  belongs_to :group
  belongs_to :question

  validates_presence_of :item_id
  validates_presence_of :ratings
  validates_presence_of :wins
  validates_presence_of :losses

  class << self
    def get(item, group, question)
      first(:conditions => { :item_id => item.id, :group_id => group.id, :question_id => question.id })
    end
  end

  def win_percent
    [wins, losses].to_percent
  end
end
