class Admin::GroupsController < Admin::BaseController
  # GET /admin/groups
  # GET /admin/groups.xml
  def index
    @groups = Group.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /admin/groups/1
  # GET /admin/groups/1.xml
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /admin/groups/new
  # GET /admin/groups/new.xml
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /admin/groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /admin/groups
  # POST /admin/groups.xml
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        update_translations(params, @group, 'Group')
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(admin_group_path(@group)) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/groups/1
  # PUT /admin/groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        update_translations(params, @group, 'Group')
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(admin_group_path(@group)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/groups/1
  # DELETE /admin/groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(admin_groups_path) }
      format.xml  { head :ok }
    end
  end
end
