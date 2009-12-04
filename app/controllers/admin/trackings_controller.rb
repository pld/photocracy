class Admin::TrackingsController < Admin::BaseController
  # GET /admin/trackings
  # GET /admin/trackings.xml
  def index
    @trackings = Tracking.page_find

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trackings }
    end
  end

  # GET /admin/trackings/1
  # GET /admin/trackings/1.xml
  def show
    @tracking = Tracking.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tracking }
    end
  end
end
