# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  include ReCaptcha::AppHelper
  include Constants::Login

  skip_before_filter :login_required
  before_filter :logout_required, :except => :destroy
  before_filter :captcha?, :only => [:new, :denied]
  after_filter :store_location, :only => :new
#  caches_page :new, :denied, :layout => false

  def new; end

  def denied; end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password]) || User.new
    @captcha_valid = (login_attempts < MAX_LOGIN_ATTEMPTS || validate_recap(params, user.errors))
    if !user.new_record? && @captcha_valid
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      setup_user
      redirect_back_or_default('/')
      failed_logins { |l| l.delete }
      flash.now[:notice] = t('sessions.success')
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    save_prompt_to_visit if active_prompt
    locale = session[:locale]
    logout_keeping_session!
    self.locale = locale
    flash.now[:notice] = t('sessions.logout')
    redirect_back_or_default('/')
  end

  def captcha?
    @captcha_valid = (login_attempts < MAX_LOGIN_ATTEMPTS || validate_recap(params, User.new.errors))
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "#{t('sessions.fail')} '#{params[:email].to_s}'"
    if @captcha_valid == false
      flash.now[:error] = "#{t('sessions.captcha_error')}<br/><br/>#{flash[:error]}"
    else
      failed_logins { |logins| logins.update_attribute(:value, logins.value.to_i + 1) } ||
      Param.create(:name => current_visit.ip_address, :value => 1)
    end
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} with visit #{current_visit_id} at #{Time.now.utc}"
  end
end