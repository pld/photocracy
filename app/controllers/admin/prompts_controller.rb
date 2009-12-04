class Admin::PromptsController < Admin::BaseController
  # GET /prompts
  # GET /prompts.xml
  def index
    @prompts = Prompt.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @prompts }
    end
  end

  # GET /prompts/1
  # GET /prompts/1.xml
  def show
    @prompt = Prompt.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @prompt }
    end
  end
end
