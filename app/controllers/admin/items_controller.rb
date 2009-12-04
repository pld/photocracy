class Admin::ItemsController < Admin::BaseController
  include Systems::Flickr

  def index
    @items = Item.page_find
  end

  def flagged
    @items = Item.all(:include => [:flags, :questions], :conditions => 'flags.item_id IS NOT NULL', :order => 'flags.updated_at desc').paginate
    
    render :action => 'index'
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        flash[:notice] = 'Item was successfully updated.'
        format.html { redirect_to(:action => :index) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new
    @item = Item.new
    # don't pull up uncleaned files
    Dir["#{Constants::Config::DIR_PATH}/*"].each { |file| File.delete(file) }
  end

#  def create
#    params[:item].merge!(:agree => '1')
#    zip = params[:item].delete(:uploaded_data)
#    %x(unzip -joqq -d #{Constants::Config::DIR_PATH} #{zip.path})
#    File.delete(zip.path)
#    files = Dir["#{Constants::Config::DIR_PATH}/*"]
#    files.each do |file|
#      data = temp_file_for_path(file)
#      item = Item.new(params[:item])
#      attachment = Attachment.new(params[:attachment].merge({ :uploaded_data => data }))
#      questions = params[:question].values.uniq.compact.reject! { |el| el.empty? }
#      Item.new_remote(item, attachment, questions, active_visit.id)
#    end
#    files.each { |file| File.delete(file) }
#    flash[:notice] = 'The files have been uploaded'#'The file is being processed...'
#    redirect_to admin_items_path
#  ensure
#    GC.start
#  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  # def destroy
  #   @item = Item.find(params[:id])
  #   @item.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(admin_items_path) }
  #     format.xml  { head :ok }
  #   end
  # end

  def flick
    if request.post? && ids = params[:photo_ids]
      activate = !params[:activate].nil?
      data = []
      Flickr.transaction do
        Item.transaction do
          data = ids.split("\n").map(&:chomp).inject([]) do |array, id|
            path, data = temp_file_for_flickr_id(id)
            item, flickr = data_for_flickr_id(id)
            unless item && flickr
              flash[:error] = "Photo ID '#{id}' is invalid."
              redirect_to admin_items_path
              return
            end
            params[:item] = { :agree => '1' }.merge(item)
            item = Item.new(params[:item])
            attachment = Attachment.new(:uploaded_data => data)
            questions = params[:question].values.uniq.compact.reject { |el| el.empty? }
            File.delete(path)
            array << [item, attachment, questions, flickr]
          end
        end
      end
      Flickr.transaction do
        Item.transaction do
          data.each do |item, attachment, questions, flickr|
            item = Item.new_remote(item, attachment, questions, current_visit_id)
            Flickr.create!(flickr.merge(:item_id => item.id))
            item.activate if activate
          end
        end
      end
      flash[:notice] = 'The photos have been uploaded'
      redirect_to admin_items_path
    end
  ensure
    GC.start
  end

  def add_question
    render :update do |page|
      page[:questions].append render(:partial => 'questions', :locals => { :num => params[:num].to_i + 1 })
    end
  end

  def merge
  end
end