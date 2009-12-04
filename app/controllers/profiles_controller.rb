class ProfilesController < ApplicationController
  before_filter :admin_required, :only => :index
  before_filter :login_required, :except => :language
  before_filter :profile_required, :only => [:edit, :update, :show]
  before_filter :no_profile_required, :only => [:new, :create]
  after_filter :store_location, :only => :show

  include Constants::Profile

  # GET /profiles
  # GET /profiles.xml
  def index
    @profiles = Profile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    @profile = current_user.profile(:include => :profile_questions)
    @limit = LAST_ITEMS_LIMIT
    @items = fetch_user_items(false)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/new
  # GET /profiles/new.xml
  def new
    @profile = Profile.new
    @header = t('profile.new')
    respond_to do |format|
      format.html { render :action => 'edit' }
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    @header = t('profile.edit')
    @profile = current_user.profile
    # raise @profile.date_of_birth.inspect
  end

  # POST /profiles
  # POST /profiles.xml
  def create
    @profile = Profile.new(params[:profile].merge(:user_id => current_user.id))

    respond_to do |format|
      if @profile.save
        save_profile_questions(@profile, params[:profile_question])
        flash[:notice] = t 'profile.success'
        format.html { redirect_to(@profile) }
        format.xml  { render :xml => @profile, :status => :created, :location => @profile }
      else
        @header = t('profile.new')
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    @profile = current_user.profile

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        save_profile_questions(@profile, params[:profile_question])
        flash[:notice] = t('profile.success')
        format.html { redirect_to(@profile) }
        format.xml  { head :ok }
      else
        @header = t('profile.edit')
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /profiles/language
  def language
    if locale = valid_locale(params[:id])
      if logged_in?
        if profile = current_user.profile
          profile.update_attribute(:locale, locale)
        else
          Profile.create(:user_id => current_user.id, :locale => locale)
        end
      end
      # start a new visit on locale change so that we can track finer grained
      create_visit(locale)
      I18n.locale = self.locale = locale
    end
    params[:q].to_i > 0 ? redirect_to(response_path(params[:q].to_i)) : redirect_back_or_default(:root)
  end

private
  def valid_locale(locale)
    Constants::Locales::CODES.include?(locale) ? locale : false
  end

  def no_profile_required
    if current_user.profile
      redirect_to :action => :edit
      return
    end
  end

  def profile_required
    unless current_user.profile
      redirect_to :action => :new
      return
    end
  end
end