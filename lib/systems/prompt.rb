module Systems::Prompt
  def last_prompt
    session[:last_prompt_id]
  end

  def reset_last_prompt
    session[:last_prompt_id] = nil
  end

  def question_prompts_shown
    session[:question_prompts_shown].to_i
  end

  def prompts_shown
    session[:prompts_shown].to_i
  end

  def active_prompt=(prompt)
    if active_prompt != prompt
      Pairwise.view(prompt.prompt_id_ext)
      session[:last_prompt_id] = active_prompt && active_prompt.id
      session[:active_prompt] = prompt
    end
  end

  def increment_prompts_shown
    session[:question_prompts_shown] ||= 0
    session[:prompts_shown] ||= 0
    session[:prompts_shown] += 1
    session[:question_prompts_shown] += 1
  end

  def active_prompt
    session[:active_prompt]
  end

  def save_prompt_to_visit
    visit = current_visit
    visit && visit.update_attribute(:prompt_id, active_prompt)
  end

  def prompts_left_for_question
    refresh_question_after - question_prompts_shown
  end

  def assign_prompt
    if active_prompt
      ::Prompt.find(active_prompt).update_attribute(:user_id, current_user.id)
    end
  end
end