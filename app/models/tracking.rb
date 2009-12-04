class Tracking < ActiveRecord::Base
  belongs_to :visit

  validates_presence_of :visit_id
  validates_presence_of :controller
  validates_presence_of :action

  class << self
    def per_page; 25 end

    def page_find(page = 1)
      paginate(:page => page, :order => "trackings.created_at desc")
    end
  end
end
