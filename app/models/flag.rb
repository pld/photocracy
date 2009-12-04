class Flag < ActiveRecord::Base
  belongs_to :flag_type
  belongs_to :visit
  belongs_to :item
  belongs_to :comment
  
  validates_presence_of :flag_type_id
  validates_presence_of :visit_id
  validates_presence_of :item_id, :if => lambda { |obj| obj.comment_id.nil? }
  validates_presence_of :comment_id, :if => lambda { |obj| obj.item_id.nil? }

  after_create lambda { |flag| Mailer.deliver_flagged(flag) }

  def self.uniq_ip_count(obj, active_only = false)
    conditions = (active_only) ? { :active => true } : {}
    if obj.class == Item
      conditions[:item_id] = obj.id
    elsif obj.class == Comment
      conditions[:comment_id] = obj.id
    end
    count(
      :joins => "INNER JOIN visits ON visits.id=flags.visit_id",
      :conditions => conditions,
      :group => 'visits.ip_address'
    ).values.length
  end

  def self.count_active
    count(:conditions => { :active => true })
  end

  def suspend(count_active_only = true)
    if self.item # suspend item
      self.item.suspend if Flag.uniq_ip_count(self.item, count_active_only) >= Param.item_flags_for_suspend
    elsif self.comment # suspend comment
      self.comment.suspend if Flag.uniq_ip_count(self.comment, count_active_only) >= Param.comment_flags_for_suspend
    end
  end
end
