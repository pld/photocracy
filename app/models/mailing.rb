class Mailing < ActiveRecord::Base
  belongs_to :user
  belongs_to :visit
  belongs_to :item

  validates_presence_of :visit_id
  validates_presence_of :user_id, :if => lambda { |mail| mail.mail_type.nil? }
  validates_presence_of :name, :if => lambda { |mail| mail.mail_type.nil? }
  validates_presence_of :email, :if => lambda { |mail| mail.mail_type.nil? }
  validates_length_of   :email,    :within => 6..100, :if => lambda { |mail| mail.mail_type.nil? }
  validates_format_of   :email,    :with => Authentication.email_regex, :if => lambda { |mail| mail.mail_type.nil? }
  validates_presence_of :message

  def send_item
    Mailer.deliver_item(self)
    update_attribute :sent, true
  end

  def send_share
    Mailer.deliver_share(self)
    update_attribute :sent, true
  end

  def send_feedback
    self.email ||= current_user.email
    self.save!
    Mailer.deliver_feedback(self)
    update_attribute :sent, true
  end

  def send_reset_password(activation_code)
    Mailer.deliver_reset_password(self, activation_code)
    update_attribute :sent, true
  end
end
