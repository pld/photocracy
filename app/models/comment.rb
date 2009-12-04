class Comment < ActiveRecord::Base
  belongs_to :visit
  belongs_to :item
  has_many :flags

  validates_presence_of :item_id
  validates_presence_of :visit_id
  validates_presence_of :content

  acts_as_sanitized :fields => [ :content ], :strip_tags => true

  def suspend
    update_attribute(:active, false)
  end

  def activate
    update_attribute(:active, true)
  end

  class << self
    def per_page; 25 end

    def page_find(page = 1)
      paginate(:page => page, :order => "comments.created_at desc")
    end

    def ordered_active(item_id = nil)
      conditions = { :order => "created_at DESC", :conditions => { :active => true } }
      if item_id
        find_all_by_item_id(item_id, conditions)
      else
        all(conditions)
      end
    end
  end
end
