class Admin::ResponsesController < Admin::BaseController
  # GET /prompts
  # GET /prompts.xml
  def index
    @responses = Response.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @responses }
    end
  end

  # GET /responses/1
  # GET /responses/1.xml
  def show
    @response = Response.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @response }
    end
  end
end