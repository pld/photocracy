class Visit < ActiveRecord::Base
  belongs_to :user
  has_one :prompt
  has_many :comments
  has_many :flags
  has_many :items
  has_many :prompts
  has_many :responses
  has_many :trackings

  validates_presence_of :ip_address

  def locked?
    self.lock == true
  end

  def lock!
    update_attribute('lock', true)
  end

  def unlock
    update_attribute('lock', false)
  end

  class << self
    def per_page; 25 end

    def page_find(page = 1)
      paginate(:page => page, :order => "visits.created_at desc")
    end
  end
end
