module Systems::Question
  def active_question(id = nil)
    if session[:question].nil?
      # this is the first question
      if id
        begin
          q = ::Question.find(id)
        rescue
        end
      end
      q = ::Question.fetch_first if q.nil?
    elsif refresh_question? || @new_question
      q = next_question
      self.next_question = nil
    end
    if q
      session[:question_prompts_shown] = 0
      session[:question_responses] = 0
      session[:question] = q
    else
      session[:question]
    end
  end

  def get_next_question
    cond = "questions.id != #{session[:question].id}"
    session[:next_question] = ::Question.fetch_new(cond)
  end

  def next_question
    session[:next_question] || get_next_question
  end

  def next_question=(q)
    session[:next_question] = q
  end

  def current_question
    session[:question] || active_question
  end

  def question_responses
    session[:question_responses] || 0
  end

  def refresh_question_after
    current_visit.prompts_per_question || Param.refresh_question_after
  end

  # refresh question if over N questions asked
  def refresh_question?
    question_responses >= refresh_question_after
  end
end