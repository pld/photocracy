class ItemsController < ApplicationController
  include Systems::Flickr

  before_filter(:only => [:new, :create, :comment, :share]) { |c| c.nice_login_required }
  before_filter(:only => :index) { |c| c.login_required?(:items) }
  before_filter(:only => :show) { |c| c.login_required?(:item) }
  before_filter :fetch_recent_items, :only => [:new, :create]
  after_filter :store_location, :only => [:index, :show, :new]
  # caches_page :index, :expires_in => 15.minutes, :layout => false
  # caches_page :show, :flag, :layout => false
  # caches_page :country, :paginate
  # caches_action :new, :comment, :share, :layout => false

  # GET /items
  # GET /items.xml
  def index
    @active_question_id = current_question.id
    @questions = Question.all
    fetch_stats(paginate_options, @questions)
    fetch_user_items
  end

  def image
    @attachment = Item.find(params[:id]).attachment
    send_data(@attachment.public_filename(:compare), :type => @attachment.content_type, :disposition => 'attachment')
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @current_user = current_user
    conditions = @admin_user ? {} : { :conditions => { :active => true } }
    @item = Item.find(params[:id], conditions)
    @groups = Group.all(:select => 'code, name, id')
  rescue ActiveRecord::RecordNotFound
    redirect_to items_path
    return
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.new
    @item_type = 'upload'
    @questions = [current_question.id]
    fetch_user_items
  end

  # POST /items
  # POST /items.xml
  # can we do this asynchronously?
  def create
    @item_type = params[:item_type]
    @item = Item.new(params[:item])
    @question = params[:question][:id].to_i
    if params[:item][:agree] == '1'
      data = nil
      case @item_type
      when 'flickr'
        if id = flickr?(params)
          begin
            @path, data = temp_file_for_flickr_id(id)
            item, flickr = data_for_flickr_id(id)
            if item && flickr
              @item.external_link = item[:external_link]
            else
              @error = t('item.submit.flickr_fail')
            end
          rescue FlickRaw::FailedResponse
            @error = t('item.submit.flickr_fail')
          end
        end
        data || @error = t('item.submit.fail.flickr')
      when 'url'
        url = params[:url]
        if !(url.empty? || detect_content_type(url).nil?)
          @path, data = temp_file_for_url(url)
          @item.external_link = url
        end
        data || @error = t('item.submit.fail.url')
      end
      @attachment = data ? Attachment.new(:uploaded_data => data) : Attachment.new(params[:attachment])
      if Item.valid_objects(@item, @attachment, [@question])
        item = Item.new_remote(@item, @attachment, [@question], current_visit_id!)
        # create stat for the item
        for group in Group.all
          Stat.create(
            :item_id => item.id,
            :question_id => @question,
            :group_id => group.id,
            :ratings => 0,
            :wins => 0,
            :losses => 0
          )
        end
        if flickr?(params) && item
          Flickr.create(flickr.merge(:item_id => item.id))
        end
        File.delete(@path) if @path
        @item = Item.new
        @create = flash.now[:notice] = t("item.create")
      end
    end
    if flash[:notice].nil?
      @item.errors.add('id', @error || t('item.submit.fail.upload'))
      flash.now[:error] = t('item.submit.fail.h')
    end
    fetch_user_items
    render :action => 'new'
  ensure
    GC.start # cleanup memory
  end

  def flag
    unless (flag = flag_obj(params[:flag])).new_record?
      flash.now[:notice] = flag.item_id ? t('item.flag.success') : t('comment.flag.success')
      if flag.item_id
        redirect_to items_path
      else
        redirect_to item_path(flag.comment.item_id)
      end
    else
      @item = Item.find(params[:flag][:item_id], :conditions => { :active => true })
      @flag = flag
      render :action => 'show'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to items_path
    return
  end

  def comment
    user = current_user
    user.update_attributes(:login => params[:user][:login]) if user.login.nil? || user.login.empty?
    params[:comment].merge!(:active => false) unless Param.boolean(Constants::Params::NO_MODERATE_COMMENTS)
    comment = Comment.new(params[:comment].merge(:visit_id => current_visit_id!))
    render :update do |page|
      if user.valid? && comment.save
        page[:login].html("<p>#{t('form.how_you_appear')}: <strong>#{current_user.login}</strong></p>") if params[:user] and params[:user][:login]
        comments = Comment.ordered_active(comment.item_id)
        notify(page, t('comment.success'))
        page[:comment_errors].html ''
        page[:comment_content].value = ''
        page[:comments_count].html comments.length
        page[:comments].html render(:partial => 'comment', :collection => comments)
      else
        error = user.valid? ? comment.errors.full_messages : "#{t('form.user_name')} #{user.errors.on('login')}"
        page[:comment_errors].html content_tag(:div, error, :class => 'errorExplanation')
      end
    end
  end

  def tag
    @item = Item.find(params[:tag][:item_id])
    context = Question.find(params[:tag][:question_id], :include => :groups).groups.first.code.to_sym
    @item.set_tag_list_on(context, "#{@item.tag_list_on(context)},#{params[:tag][:content]}")
    @item.save
    @item = @item.reload
    render :update do |page|
      page[:tags].html render(:partial => 'tags')
    end
  end

  def share
    @mailing = Mailing.new(setup_mail_params(params[:mailing]))
    render :update do |page|
      if @mailing.save
        page[:mailing_name].value = ''
        page[:mailing_email].value = ''
        page[:mailing_message].value = ''
        page[:mailing].hide
        notify(page, t('item.send.success'))
      else
        page[:mailing_errors].html error_messages_for('mailing')
      end
    end
    @mailing.send_item unless @mailing.new_record?
  end

  def paginate
    question = Question.find(params[:id])
    @active_question_id = question.id
    fetch_stats(paginate_options, [question])
    render :update do |page|
      page["items_#{@active_question_id}"].html render(:partial => 'item', :collection => @item_ids[question.id], :locals => { :question_id => question.id })
      page << "window.scrollTo(0,0);"
    end
  end

  def country
    session[:country_code] = params[:country_id].gsub(/\W/, '')[0,2].downcase
    questions =  Question.all
    fetch_stats(paginate_options, questions)
    render :update do |page|
      if @item_ids[params[:question_id].to_i].length < 1
        page[:flash_notice_content].html(t('items.not_enough_votes'))
        page.delay(1) { page[:flash_notice_content].fade(:duration => 1) }
      else
        @item_ids.each do |question_id, items|
          page["items_#{question_id}"].html(render(:partial => 'item', :collection => items, :locals => { :items => items, :question_id => question_id }))
          page[:flash_notice_content].fade(:duration => 1)
        end
      end
    end
  end

  def percent_order; '(items_questions.wins/items_questions.ratings) desc' end

  private
    def flickr?(params)
      !(params[:flickr_id]).empty? && params[:flickr_id]
    end

    # caching leaks
    def fetch_stats(options, questions)
      items = Item.all(options[:options].merge({
          :joins => "INNER JOIN items_questions ON (items_questions.item_id=items.id AND items_questions.question_id IN (#{questions.map(&:id).join(',')}))",
          :select => 'items.id, items.attribution, items.attachment_id'
      }))
      stats = nil
      stats = questions.inject({}) do |hash, question|
        hash[question.id] = Item.for_question(question, options[:country_code])
        hash
      end
      @item_ids, @item_data = {}, {}
      for question in questions do
        wins, ratings, percents, ranks = stats[question.id]
        current_items = items.select do |item|
          id = item.attributes['id'].to_i
          ratings[id] && ratings[id] >= Constants::Item::REJECT_WITH_RATINGS_UNDER
        end
        if options[:options][:order] == percent_order
          current_items = current_items.sort_by do |item|
            id = item.attributes['id'].to_i
            ranks[id].to_i
          end
        end
        # prefetch attachments
        attachments = Attachment.find(current_items.map(&:attachment_id)).obj_id_to_hash
        @item_data[question.id] = {}
        current_items.map! do |item|
          id = item.attributes['id'].to_i
          @item_data[question.id][id] = {
            :ratings => ratings[id],
            :wins => wins[id],
            :percent => percents[id],
            :attr => item.attribution,
            :image => attachments[item.attachment_id].public_filename(:compare)
          }
          id
        end
        @item_ids[question.id] = current_items.paginate(:page => options[:page], :per_page => Constants::Item::PER_PAGE)
        rank = 10 * (options[:page].to_i - 1)
        @item_ids[question.id].each do |id|
          @item_data[question.id][id][:rank] = rank += 1
        end
      end
    end

    def fetch_recent_items
      @items = Item.all(:order => 'created_at desc', :limit => 4, :conditions => { :active => true })
    end

    def paginate_options
      @country_code = session[:country_code]
      {
        :options => {
          :order => (session[:order] || default_order),
          :conditions => 'items.active=1',
          :group => 'items.id'
        },
        :country_code => @country_code,
        :page => params[:page] || 1
      }
    end

    def parse_order(param)
      case param
      when "new"
        'items.created_at desc'
      when "score"
        'items_questions.position desc'
      else
        default_order
      end
    end

    def reset_find_options
      session[:order] = default_order
      session[:country_code] = nil
    end

    def default_order; percent_order end
end