class Admin::FlagsController < Admin::BaseController
  # GET /flags
  # GET /flags.xml
  def index
    @flags = Flag.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @flags }
    end
  end

  # GET /flags/1
  # GET /flags/1.xml
  def show
    @flag = Flag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @flag }
    end
  end

  # DELETE /flags/1
  # DELETE /flags/1.xml
  def destroy
    @flag = Flag.find(params[:id])
    @flag.destroy

    respond_to do |format|
      format.html { redirect_to(admin_flags_url) }
      format.xml  { head :ok }
    end
  end
end
