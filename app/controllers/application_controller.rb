class ApplicationController < ActionController::Base
  if LOG_DETAIL
    include Oink::MemoryUsageLogger
    include Oink::InstanceTypeCounter
  end

  include Systems::Authenticated
  include Systems::Visit
  include Systems::Prompt
  include Systems::Question
  include Systems::Locale

  helper :all # include all helpers, all the time

  # TODO enable protection after fixing cache, etc. issue
  # protect_from_forgery

  # filter parameter password from logs
  filter_parameter_logging :password, :password_confirmation

  before_filter :create_visit, :unless => lambda { |c| c.fresh_visit? }
  before_filter :clear_track_set_get

  if ENV['RAILS_ENV'] == 'production'
    rescue_from Exception do |e| notify_and_handle(e) end
  end

  def clear_track_set_get
    track
    set_locale
    get_stats
    @logged_in = logged_in?
    @admin_user = @logged_in && admin_user?
    headers['P3P'] = %|CP="CAO PSA OUR", policyref="#{Constants::Urls::P3P}"|
  end

  def closed
    if request.xhr?
      render :update do |page|
        page.redirect_to(about_path)
      end
    else
      redirect_to(about_path)
    end
  end

  def flag_obj(params)
    params[:visit_id] = current_visit_id!
    flag = Flag.create(params)
    flag.suspend unless flag.new_record?
    flag
  end

  def track
    params_  = params.clone # don't corrupt real params
    Tracking.create(
      :visit_id => current_visit_id!,
      :controller => params_.delete(:controller),
      :action => params_.delete(:action),
      :mouse => params_.delete(:mouse),
      :parameters => params_.inspect
    )
  end

  def setup_user
    self.locale = current_user.profile && current_user.profile.locale
    assign_locale
    assign_prompt
    create_visit
  end

  def get_stats
    @total_votes ||= Response.count(:conditions => { :active => true }).to_s
    @total_items ||= Item.count(:conditions => { :active => true }).to_s
  end

  def save_profile_questions(profile, params)
    return unless params
    profile_questions = profile.profile_questions
    params.each do |name, value|
      if q = profile_questions.detect { |pq| pq.name == name }
        q.update_attribute(:value, value)
      else
        ProfileQuestion.create(:profile_id => profile.id, :name => name, :value => value)
      end
    end
  end

  def detect_content_type(file)
    ext = File.extname(file).delete('.')
    ext.length > 2 ? Technoweenie::AttachmentFu.content_types.detect { |obj| obj =~ /#{ext.downcase}/ } : nil
  end

  def setup_mail_params(mail)
    mail.merge(:user_id => current_user.id, :visit_id => current_visit_id!)
  end

  def fetch_user_items(active_only = true)
    conditions = active_only ? { :active => true } : {}
    user_item_ids = current_user.item_ids(:conditions => conditions) if logged_in?
    @user_items = logged_in? ? Item.by_win_percent(
      :conditions => { :'items.id' => user_item_ids },
      :limit => Constants::Config::TOP_ITEMS_FOR_USER
    ) : []
    response_counts = Response.all(
      :select => 'items_responses.item_id, COUNT(*) AS responses',
      :conditions => { :'items_responses.item_id' => @user_items.map(&:id) },
      :joins => "INNER JOIN items_responses ON (items_responses.response_id=responses.id)",
      :group => "items_responses.item_id"
    ).inject({}) { |hash, el| hash[el.item_id.to_i] = el.responses; hash }
    @user_item_info = @user_items.inject({}) do |hash, item|
      hash[item.id] = "<strong>#{response_counts[item.id]}</strong>"
      hash
    end
  end

  # temp file creator
  def temp_file_for_url(url)
    path = "#{Constants::Config::DIR_PATH}/#{File.basename(url)}"
    url = URI.parse(url)
    Net::HTTP.start(url.host, url.port) do |http|
      resp = http.get(url.path)
      open(path, "wb") { |file| file.write(resp.body) }
    end
    return nil unless File.exists?(path)
    data = ActionController::UploadedTempfile.new(File.basename(path))
    data.content_type = detect_content_type(path)
    data.original_path = path
    FileUtils.copy_file(data.original_path, data.path)
    [path, data]
  rescue URI::InvalidURIError
    false
  end



  private
    def deactivate_admin_responses
      current_user.visits
      response_ids = Response.all(:conditions => { :active => true, :visit_id => current_user.visits }).map(&:id)
      Response.update_all("active=0", "responses.active=1 AND responses.id IN (#{response_ids.join(',')})") unless response_ids.empty?
      flash.now[:error] = "#{response_ids.length} of #{current_user.email}'s admin responses deactivated" if super_user?
    end

    def notify_and_handle(e)
      @requested_page= e.to_s
      if e.class == ActionController::RoutingError
        # ignore missing image error
        render :template => '/home/error' if (e.to_s =~ /system/).nil?
      elsif e.class == ActionController::UnknownAction
        @error = t('errors.e404')
        render :template => '/home/error'
      else
        SystemNotifier.deliver_exception(self, request, current_visit, e)
        flash.now[:error] = t('errors.e5xx')
        render :template => '/home/index'
      end
    end
end