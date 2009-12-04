class Admin::HomeController < Admin::BaseController

  MAINTENANCE = false

  before_filter :super_user_required, :only => [
    :update_cache,
    :deactivate_admin_responses,
    :archive,
  ]
  after_filter :store_location, :only => :index

  def index
    @maintenance = false
    @debug_percents = false
    @questions = Question.all.inject([]) do |array, el|
      array << stats_for_question(el).unshift(el.items)
    end if @debug_percents
  end

  def settings
    if id = params.delete(:id)
      param = Param.find_by_code(id)
      if request.xhr?
        value = percent_value?(id) ? 100 - params[:value].to_f : params[:value]
        if param
          param.update_attribute(:value, value)
        else
          Param.create(:name => id, :value => value)
        end
        render :update do |page|
          page.redirect_to :action => :settings, :id => nil
        end
      else
        if param && param.value == 'f'
          param.update_attribute(:value, 't')
        elsif param
          param.update_attribute(:value, 'f')
        else
          Param.create_for_code(id, 'f')
        end
        redirect_to :action => :settings, :id => nil
      end
    end
  end

  # archive and then delete data
  def archive
    if (@maintenance = MAINTENANCE) && request.post?
      # dump db
      db = PRODUCTION ? 'photocracy' : 'photocracy_stage'
      %x(~/mysqldump_script.sh #{db} VL1nd33er #{db} '#{Constants::SHARED_ROOT}db')
      # archive attachments and delete data
      path_to_attachments = "#{RAILS_ROOT}/public/system/"
      %x(~/tar_dump.sh  0000 #{path_to_attachments} && rm -rf #{path_to_attachments}0000)
      Attachment.delete_all
      Item.delete_all
      ItemsQuestion.delete_all
      Prompt.delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM `items_prompts`")
      Response.delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM `items_responses`")
      Comment.delete_all
      Flag.delete_all
      Visit.delete_all
      Tracking.delete_all
      session[:last_prompt_id] = nil
      session[:question_prompts_shown] = nil
      session[:prompts_shown] = nil
      session[:active_prompt] = nil
      session[:next_prompt_id] = nil
      session[:question] = nil
      session[:next_question]  = nil
      session[:question_responses] = nil
      session[:visit] = nil
      current_visit!
      flash[:notice] = 'Deleted and archived'
    end
    redirect_to admin_path
  end

  def generate_stats
    items = Item.all(:include => :questions)
    groups = Group.all
    Stat.transaction do
      for item in items
        for question in item.questions
          for group in groups
            losses = Response.count(
              :joins => "INNER JOIN items_responses ON (items_responses.response_id=responses.id AND items_responses.item_id IS NOT NULL AND items_responses.item_id!=#{item.id}) INNER JOIN prompts ON (responses.prompt_id=prompts.id AND prompts.question_id=#{question.id}) INNER JOIN items_prompts ON (items_prompts.prompt_id=prompts.id AND items_prompts.item_id=#{item.id})",
              :conditions => { :'responses.active' => true, 'responses.ip_country_code' => group.code }
            )
            Stat.create(
              :item_id => item.id,
              :question_id => question.id,
              :group_id => group.id,
              :ratings => item.ratings_for_country(group.code, question.id, false),
              :wins => item.wins_for_country(group.code, question.id),
              :losses => losses
            )
          end
        end
      end
    end
    redirect_to admin_path
  end

  def update_cache
    Systems::Syncing.update_cache
    flash[:notice] = "cache updated"
    redirect_to admin_path
  end

  def deactivate_admin_responses
    response_ids = Systems::Syncing.deactivate_admin_responses
    flash[:notice] = "#{response_ids.length} responses deactivated"
    redirect_to admin_path
  end

  def clean_questions
    nil_links = ItemsQuestion.find_by_sql("SELECT items_questions.id FROM items_questions LEFT OUTER JOIN items ON (items.id=items_questions.item_id) WHERE items.id IS NULL")
    nil_links.map(&:delete)
    flash[:notice] = nil_links.map(&:id).inspect
    redirect_to admin_path
  end

  private
    def stats_for_question(question)
      [
        [
          Item.ratings_overall(question),
          Item.ratings_for_country(question)
        ],
        [
          Item.wins_overall(question),
          Item.wins_for_country(question)
        ],
        question.win_percents_overall
      ]
    end

    def percent_value?(id)
      ['random_new_question_percent', 'english_vary_percent'].include?(id)
    end
end
