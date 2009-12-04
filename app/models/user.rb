require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  has_one :profile
  has_many :visits
  has_many :items, :through => :visits

  # validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40, :if => lambda { |u| u.login }
  validates_uniqueness_of   :login,    :if => lambda { |u| u.login }
  validates_format_of       :login,    :with => Authentication.login_regex, :if => lambda { |u| u.login }

  validates_format_of       :name,     :with => Authentication.name_regex, :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex
  # after_create :send_signup_email
  before_destroy lambda { |u| u.id != 1 } # can't delete first user

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  class << self
    def authenticate(email, password)
      return nil if email.blank? || password.blank?
      u = find_in_state(:first, :active, :conditions => {:email => email}) || find_in_state(:first, :admin, :conditions => {:email => email}) # need to get the salt
      u && u.authenticated?(password) ? u : nil
    end

    def per_page; 20 end

    def page_find(page = 1)
      paginate(:page => page, :order => "users.created_at desc")
    end

    def responses_rank(user)
      all(
        :select => 'users.id, COUNT(responses.id) AS num_responses',
        :joins => 'INNER JOIN visits ON visits.user_id=users.id LEFT OUTER JOIN responses ON responses.visit_id=visits.id',
        :group => 'users.id'
      ).inject({}) do |users, u|
        users[u.id] = u.num_responses.to_i
        users
      end.sort_by { |u| -u.last }.to_a.transpose.first.index(user.id).to_i + 1
    end

    def admins(options = {})
      conditions = { :'users.state' => 'admin' }.merge(options.delete(:conditions) || {})
      all({:conditions => conditions}.merge(options))
    end

    def admin_ids(options = {})
      conditions = { :'users.state' => 'admin' }.merge(options.delete(:conditions) || {})
      all({:select => 'users.id', :conditions => conditions}.merge(options)).map(&:id)
    end
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def register_voter
    if voter_id_ext.nil? && ext_id = Pairwise.voter({})
      update_attribute :voter_id_ext, ext_id.first
    end
  end

  def send_signup_email
    UserMailer.deliver_signup_notification(self)
  end

  def get_responses_rank
    self.update_attribute(:responses_rank, User.responses_rank(self)) if check_cache
    self.responses_rank
  end

  def get_responses_count
    self.update_attribute(:responses_count, Response.count(:conditions => { :visit_id => visit_ids })) if check_cache
    self.responses_count
  end

  def get_items_count
    self.update_attribute(:items_count, Item.count(:conditions => { :visit_id => visit_ids })) if check_cache
    self.items_count
  end

  def get_item_responses_count
    if check_cache
      ids = item_ids
      count = ids && !ids.empty? ? Response.count(
        :joins => "INNER JOIN items_responses ON (items_responses.response_id=responses.id AND items_responses.item_id IN (#{ids.join(',')}))"
      ) : 0
      self.update_attribute(:items_responses_count, count)
    end
    self.items_responses_count
  end

  def forgot_password(visit_id)
    self.reset!
    Mailing.create(
      :email => self.email,
      :visit_id => visit_id,
      :user_id => self.id,
      :name => self.email,
      :message => "RESET PASSWORD #{Time.now}"
    ).send_reset_password(self.activation_code)
  end

  def reset_password(password)
    self.password = self.password_confirmation = password
    self.salt = self.class.make_token
    self.save!
    self.activate!
  end

  protected
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end

    def check_cache
      @ret ||= cache_expired?
      set_cache if @ret && cache_expired?
      @ret
    end

    def cache_expired?
      !self.cached_at || Time.now - self.cached_at > Constants::Params::EXPIRE_USER_DATA_AFTER
    end

    def set_cache
      self.update_attribute(:cached_at, Time.now)
    end
end
