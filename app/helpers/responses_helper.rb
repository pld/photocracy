module ResponsesHelper
  include Constants::Responses

  def display_prompt(params, page)
    id_set(params[:alt])
    if @new_question
      session[:response_time] = []
      page << "Question.updateStart('#{@left}', '#{@right}');"
      prompt_item_update(page, @prompt, @left, @right, false)
      page.delay(Delay::ITEM / 1000.0) {
        page[:question].html rounded(@question.for_locale(I18n.locale))
        page[:flag_left].html question_image
        page[:flag_right].html question_image
        page << "Question.updateEnd('#{@left}', '#{@right}', '#{@prev_left}', '#{@prev_right}');"
      }
    end
    prompt_item_update(page, @next, @prev_left, @prev_right)
    page << "Prompt.Time.reset_()"
    page[:rated].html pluralize(@items_rated, t('stats.vote')) if @items_rated
    page[:stats].html render(:partial => 'shared/stats')
    last_left = escape_javascript(render(:partial => 'last', :locals => { :item => @prompt.items[0] }))
    last_right = escape_javascript(render(:partial => 'last', :locals => { :item => @prompt.items[1] }))
    percent_left = "#{@percent_wins[@prompt.items[0].id].round}%"
    percent_right = "#{@percent_wins[@prompt.items[1].id].round}%"
    suffix = params[:alt] == 'true' ? '' : '_alt'
    page << "Last.update('#{last_left}', '#{last_right}', '#{percent_left}', '#{percent_right}', '#{suffix}')"
  end

  def skip_link
    link_to_remote t('response.skip'), :url => { :action => :create }, :html => { :id => 'skip', :onclick => "Prompt.skip(#{progress_step})" }, :with => "Prompt.with_(#{progress_step})"
  end

  def response_question_select_tag
    select_tag 'question', question_options_for_select, :onchange => remote_function(:url => { :action => :question }, :with => option_with_('question'))
  end

  def progress_style(plus = 0)
    @progress_style ||= (width = progress_width) > 0 ? "width:#{width + plus.to_f/100}%" : ""
  end

  def question_image
    Param.flag_question_image? ? rounded(image_tag("#{@question.groups.first.code}.jpg")) : ''
  end

  def prompt_item_update(page, prompt, left_id, right_id, unlock = true)
    left, right = (prompt && !prompt.items.empty?) ? js_for_prompt(prompt) : ['','']
    page << "Prompt.update('#{left_id}', '#{right_id}', '#{left}', '#{right}', #{unlock})"
  end

  def js_for_prompt(prompt)
    add = (prompt == @next) ? 2 : 1
    [
      escape_javascript(render(:partial => 'item', :locals => { :item => prompt.items[0], :prompt => prompt, :add => add, :side => 'left' })),
      escape_javascript(render(:partial => 'item', :locals => { :item => prompt.items[1], :prompt => prompt, :add => add, :side => 'right' }))
    ]
  end

  def progress_step
    @progress_step ||= (100 * (1 / @controller.refresh_question_after.to_f)).ceil
  end

  def progress_width(add = 0)
    (100 * (@controller.question_responses + add) / @controller.refresh_question_after.to_f).ceil
  end

  def id_set(alt = 'true')
    @left = @prev_left = '#item_left'
    @right = @prev_right = '#item_right'
    @last_left = @prev_last_left = '#last_percent_left'
    @last_right = @prev_last_right = '#last_percent_right'
    if alt == 'true'
      @left += ALT
      @right += ALT
      @last_left += ALT
      @last_right += ALT
    else
      @prev_left += ALT
      @prev_right += ALT
      @prev_last_left += ALT
      @prev_last_right += ALT
    end
  end
end
