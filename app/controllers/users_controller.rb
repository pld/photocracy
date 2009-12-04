require 'recaptcha'

class UsersController < ApplicationController
  include ReCaptcha::AppHelper

  skip_before_filter :login_required
  before_filter :logout_required, :except => :profile
  after_filter :store_location, :only => :new

  def new
    @user = User.new
    @user.password = @user.password_confirmation = nil
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    captcha_valid = validate_recap(params, @user.errors)
    success = @user && captcha_valid && @user.valid?
    @user.register! if success
    if success && @user.errors.empty?
      # register user with Pairwise
      @user.register_voter
      # active
      @user.activate!
      # signin
      self.current_user = @user
      setup_user
      @profile = Profile.new
      @header = t('profile.new')
      @sel_options
      flash[:notice] = t('sessions.success')
      render :template => 'profiles/edit'
    else
      @user.valid?
      @user.password = @user.password_confirmation = nil
      flash.now[:error] = captcha_valid ? t('users.error') : t('users.captcha_error')
      render :action => 'new'
    end
  end

  def profile
    @user = current_user
    if request.post?
      @user.update_attributes(:login => params[:user][:login]) unless params[:user][:login].empty?
      @profile = Profile.new(params[:profile].merge(:user_id => @user.id))
      save_profile_questions(@profile, params[:profile_question]) if @profile.save
      assign_locale
      redirect_back_or_default('/')
      flash[:notice] = t('profile.success')
    end
  end

  def forgot
    if request.post?
      user = User.first({:conditions => { :email => params[:email] } })
      if user
        user.forgot_password(current_visit_id)
        flash[:notice] = t('users.forgot.success')
        redirect_back_or_default('/')
      else
        flash[:error].now = "#{t('users.forgot.no_email')}: #{params[:email]}"
      end
    end
  end

  def reset
   if request.post?
     user = User.find(params[:id])
     if (password = params[:password]) == params[:password_confirmation]
       user.reset_password(password)
       flash[:notice] = t('users.reset.success')
       redirect_to login_path
     else
       @user_id = user.id
       flash.now[:error] = t('users.reset.fail.pass')
     end
   else
     user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
     unless !params[:activation_code].blank? && user && !user.active?
       flash[:notice] = t "users.reset.fail.code"
       redirect_back_or_default('/')
     end
     @user_id = user.id
   end
  end

  def activate
   logout_keeping_session!
   user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
   case
   when (!params[:activation_code].blank?) && user && !user.active?
     # register with Pairwise if still unregistered
     user.register_voter
     user.activate!
     flash[:notice] = t "users.activate.success"
     redirect_to '/login'
   when params[:activation_code].blank?
     flash[:error] = t "users.activate.fail_missing"
     redirect_back_or_default('/')
   else
     flash[:error] = t "users.activate.fail_code"
     redirect_back_or_default('/')
   end
  end

  def show
    @user = current_user
    @profile = @user.profile
  end
end