class ResponsesController < ApplicationController
  include Systems::PromptStore
  include Constants::Responses
  include Constants::Prompts

  before_filter(:only => :index) { |c| c.login_required?(:recent) }
  skip_before_filter :get_stats, :only => [:create]
  after_filter :store_location, :only => [:index, :show]

  # GET /responses
  # GET /responses.xml
  def index
    @question = active_question
    fetch_user_items
    fetch_responses
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @responses }
    end
  end

  def question
    @question = Question.find(params[:question_id])
    fetch_responses
    render :update do |page|
      page[:responses].html render(:partial => 'response', :collection => @responses)
    end
  end

  # GET /responses/[id]
  def show
    id = params[:id].to_i
    return unless get_vars(active_prompt, id > 0 && id) { fetch_prompt }
    @prompt_js = true
    begin
      @last = last_prompt && Prompt.find(last_prompt)
    rescue ActiveRecord::RecordNotFound
      reset_last_prompt
    end
    session[:response_time] = []
    @current_percent_wins = Item.win_percents_overall_array(@prompt.question.id, @prompt.item_ids)
    @last_percent_wins = Item.win_percents_overall_array(@last.question.id, @last.item_ids) if @last
    if @logged_in
      @current_user_email = current_user.email
      @rank ||= current_user.get_responses_rank
      @items ||= current_user.get_items_count
      @items_votes ||= current_user.get_item_responses_count.round
    end
    @items_rated = @logged_in ? current_user.get_responses_count.round : (prompts_shown - 1)
    render :action => 'new'
  end

  # GET /responses/new
  def new
    redirect_to response_path(0)
  end

  # POST /responses
  # POST /responses.xml
  def create
    @items_rated = logged_in? ? current_user.responses_count.round : (prompts_shown - 1)
    response_time = parse_response_time(params[:response_time])
    begin
      last = Prompt.find(params[:prompt_id], :include => [:items, :question])
      store_response(last, params[:item_id].to_i, last.question.id, response_time)
    rescue ActiveRecord::RecordNotFound
      # the user voted on a stale prompt, pretend their vote was stored
      session[:question_responses] ||= 0
      session[:question_responses] += 1
    end
    # base new question on user's expectation via param
    self.fetch_next = nil if params[:second_last] == 'true'
    @new_question = (params[:new_question] == 'true')
    return unless get_vars(next_prompt) { prompts_left_for_question > 0 ? fetch_prompt : nil }
    @percent_wins = Item.win_percents_overall(@prompt.question_id, @prompt.item_ids)
    get_stats
    render :update do |page|
      # all votes count as optimizer hits, remove admin from here after testing?
      page << "Google.optimize();" if PRODUCTION && I18n.locale == 'en'
      # only when we've seen our second prompt will prompts_shown be < 3
      page << "Google.conversion('0R6LCIK1hAEQxNKW9gM');" if @controller.prompts_shown < 3
      page << "Google.conversion('D3UMCLa2hAEQxNKW9gM');" if @new_question
      display_prompt(params, page)
    end
  end

  def flag
    flag_obj(params[:flag])  # we don't check validity
    get_vars(next_prompt, nil, false)
    render :update do |page|
      flash[:notice] = t('flag.success')
      page.redirect_to(root_path)
    end
  end

  private
    def get_vars(prompt, id = nil, increment = true, &blk)
      @exp_locale = exp_locale
      @question = active_question(id)
      if @question
        self.prompt_question = @question
        set_user_ids
        update_prompts(prompt, increment, &blk)
        @prompt = current_prompt
        @prompt_items = @prompt.items if @prompt
        @next = next_prompt
        @next_items = @next.items if @next
      end
      (@question && @prompt) || (closed && false)
    end

    # response time converted to 100ths of a second
    def parse_response_time(time)
      time.to_i / MS_FACTOR
    end

    def set_user_ids
      if @logged_in
        self.user_ext_id = current_user.voter_id_ext || Constants::Prompts::ANONYMOUS_USER_ID
        self.user_id = current_user.id
      else
        self.user_ext_id = Constants::Prompts::ANONYMOUS_USER_ID
        self.user_id = Constants::Prompts::ANONYMOUS_USER_ID
      end
    end

    def fetch_responses
      @limit = NUM_RECENT_RESPONSES.to_s
      responses = Response.all(
        :order => "responses.id desc",
        :limit => @limit,
        :include => { :items => :attachment, :prompt => { :items => :attachment } },
        :conditions => { 'prompts.question_id' => @question, :active => true }
      )
      @responses = responses.inject([]) do |arr, response|
        arr << [response.items, response.prompt.items - response.items]
        arr
      end
    end

    def store_response(last, item_id, question_id, response_time)
      winner = item_id > 0 ? Item.find(item_id) : false
      session[:question_responses] ||= 0
      session[:question_responses] += 1
      response = Response.create_for_prompt(last, winner && winner.item_id_ext, user_ext_id,
        { :visit_id => current_visit_id!,
          :response_time => response_time,
          :prompt_id => last.id,
          :ip_country_code => current_visit_ip_country_code,
          :active => admin_user? ? false : true
      })
      if response && response.active
        group = current_visit_ip_country_code && Group.first(:conditions => "groups.code LIKE '#{current_visit_ip_country_code.downcase}'")
        for item in last.items.all(:include => :items_questions, :conditions => { :'items_questions.question_id' => question_id })
          response_type = (winner == item) ? :wins : :losses
          if group
            stat = Stat.first(:conditions => {
              :question_id => question_id,
              :group_id => group.id,
              :item_id => item.id
            })
            stat.increment!(:ratings)
            stat.increment!(response_type)
          end
          iq = item.items_questions.first
          iq.increment!(:ratings)
          iq.increment!(response_type)
        end
        response.items << winner if winner
      end
      winner
    end
end