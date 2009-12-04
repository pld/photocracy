class Admin::FlagTypesController < Admin::BaseController
  # GET /flag_types
  # GET /flag_types.xml
  def index
    @flag_types = FlagType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @flag_types }
    end
  end

  # GET /flag_types/1
  # GET /flag_types/1.xml
  def show
    @flag_type = FlagType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @flag_type }
    end
  end

  # GET /flag_types/new
  # GET /flag_types/new.xml
  def new
    @flag_type = FlagType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @flag_type }
    end
  end

  # GET /flag_types/1/edit
  def edit
    @flag_type = FlagType.find(params[:id])
  end

  # POST /flag_types
  # POST /flag_types.xml
  def create
    @flag_type = FlagType.new(params[:flag_type])

    respond_to do |format|
      if @flag_type.save
        flash[:notice] = 'FlagType was successfully created.'
        format.html { redirect_to(admin_flag_type_url(@flag_type)) }
        format.xml  { render :xml => @flag_type, :status => :created, :location => @flag_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @flag_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /flag_types/1
  # PUT /flag_types/1.xml
  def update
    @flag_type = FlagType.find(params[:id])

    respond_to do |format|
      if @flag_type.update_attributes(params[:flag_type])
        flash[:notice] = 'FlagType was successfully updated.'
        format.html { redirect_to(admin_flag_type_url(@flag_type)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @flag_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /flag_types/1
  # DELETE /flag_types/1.xml
  def destroy
    @flag_type = FlagType.find(params[:id])
    @flag_type.destroy

    respond_to do |format|
      format.html { redirect_to(admin_flag_types_url) }
      format.xml  { head :ok }
    end
  end
end
