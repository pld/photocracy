module Systems::Visit
  def assign_visit
    active_visit.update_attribute :user_id, current_user.id
  end

  def active_visit=(visit)
    session[:visit_id] = visit.id
    session[:visit_ip_country_code] = visit.ip_country_code
  end

  def current_visit_id
    session[:visit_id]
  end

  def current_visit_id!
    session[:visit_id] || create_visit.id
  end

  def current_visit_ip_country_code
    session[:visit_ip_country_code]
  end

  def exp_locale
    session[:exp_locale]
  end

  def current_visit
    current_visit_id && ::Visit.find(current_visit_id)
  end

  def current_visit!
    (current_visit_id && ::Visit.find(current_visit_id)) || create_visit
  end

  # time out visit if updated_at + const > now
  def fresh_visit?
    visit = current_visit
    visit && visit.updated_at + Constants::Config::VISIT_STALE_AFTER > Time.now
  end

  def create_visit(locale = false)
    # if creating because of stale visit store last prompt in old visit
    save_prompt_to_visit if current_visit_id
    ip = request.env['HTTP_X_REAL_IP'] || request.env['REMOTE_ADDR']
    visit = ::Visit.new do |v|
      v.user_id = current_user.id if current_user
      v.host = request.env['HTTP_HOST']
      v.user_agent = request.env['HTTP_USER_AGENT']
      v.referrer = request.env['HTTP_REFERER']
      v.request_uri = request.env['REQUEST_URI']
    end
    visit = GeoIP.location(ip, visit)
    visit.locale = locale ? locale : assign_locale(visit)
    # assign the user an text experiment locale?
    visit.locale = session[:exp_locale] = (rand < Param.english_vary_prob) ? 'e2' : nil if visit.locale == Constants::Locales::DEFAULT
    # assign the user a prompts per question experiment
    visit.prompts_per_question = 4 + rand(7) # random length between 4 and 10
    visit.ip_address = (!visit.ip_country_code.nil? && Constants::Config::HASH_IP) ? Digest::SHA1.hexdigest(ip) : ip
    visit.save!
    self.active_visit = visit
    visit
  end
end