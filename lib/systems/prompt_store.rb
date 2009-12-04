module Systems::PromptStore
  attr_reader :current_prompt, :fetch_to_cache
  attr_accessor :user_ext_id, :user_id, :prompt_question, :fetch_next

  def update_prompts(prompt, increment = true, &blk)
    @current_prompt = prompt || blk && blk.call
    # check for stale prompts
    @current_prompt = fetch_prompt unless current_prompt && Prompt.exists?(current_prompt.id)
    increment_prompts_shown if increment && active_prompt != current_prompt
    fetch_prompts
  end

  def next_prompt!
    prompts_left_for_question > 0 ? fetch_prompt : nil
  end

  def next_prompt
    session[:next_prompt]
  end

  def next_prompt=(prompt)
    session[:next_prompt] = prompt
  end

  def fetch_prompts
    self.active_prompt = @current_prompt
    self.next_prompt = next_prompt!
    if @fetch_to_cache == true && question_responses > 0
      # fetch for current if signalled this round and not first prompts
      @fetch_to_cache = false
      fetch_to_cache(prompt_question)
    elsif self.fetch_next ||= (question_responses > (refresh_question_after / 2))
      # fetch for next if not set false and more than half way through prompts
      self.fetch_next = false
      fetch_to_cache(next_question) if ::Prompt.fetch_more?(user_id, current_visit_id!, next_question.id)
    end
  end

  def fetch_prompt
    prompt, @fetch_to_cache = ::Prompt.fetch(
      user_id,
      user_ext_id,
      prompt_question,
      current_visit_id!,
      prompts_shown
    )
    prompt
  end

  private
    def fetch_to_cache(q)
      ::Prompt.pairwise_fetch(q, user_ext_id, user_id, current_visit_id!, Param.refresh_question_after.to_i)
    end
end