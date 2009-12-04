class Admin::VisitsController < Admin::BaseController
  # GET /visits
  # GET /visits.xml
  def index
    @visits = Visit.page_find

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @visits }
    end
  end

  # GET /visits/1
  # GET /visits/1.xml
  def show
    @visit = Visit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @visit }
    end
  end

  def locate
    visits = Visit.all(:conditions => "visits.ip_address LIKE '%.%'")
    visits.each do |visit|
      visit = GeoIP.location(visit.ip_address, visit)
      visit.ip_address = Digest::SHA1.hexdigest(visit.ip_address) if (!visit.ip_country_code.nil? && Constants::Config::HASH_IP)
      visit.save!
    end
    flash[:notice] = "Parsing in progress..."
    redirect_to admin_visits_path
  end
end
