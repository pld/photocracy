class HomeController < ApplicationController
  before_filter :login_required, :only => :share
  after_filter :store_location, :only => [:index, :privacy, :feedback, :share]
#  caches_page :index, :privacy, :feedback, :error, :layout => false
#  caches_action :share, :layout => false

  def index
  end

  def privacy
  end

  def feedback
    if request.post?
      @feedback = Mailing.new(setup_mail_params(params[:mailing]))
      if @feedback.save
        @feedback.send_feedback
        flash[:notice] = t('feedback.success')
        redirect_to root_path
      elsif @feedback.valid?
        flash[:error] = t('mailing.failure')
      end
    else
      @feedback = Mailing.new
    end
  end

  def error
    @error = t('errors.e404')
  end

  def stats
  end

  def share
    if request.post?
      @mailing = Mailing.new(setup_mail_params(params[:mailing]))
      if @mailing.save
        @mailing.send_share
        flash[:notice] = t('mailing.success')
        redirect_to root_path
      elsif @mailing.valid?
        flash[:error] = t('mailing.failure')
      end
    else
      @mailing = Mailing.new
    end
  end
end
