class Admin::ExperimentsController < Admin::BaseController
  def index
    code = 'en'
    exp_code = 'e2'
    questions = Question.all
    visit_id = Visit.first(:conditions => { :locale => exp_code }, :select => 'id').id
    @question_counts = questions.inject([]) do |array, question|
      array << Response.count(
        :joins => "INNER JOIN prompts ON (prompts.id=responses.prompt_id) INNER JOIN visits ON (responses.visit_id>=#{visit_id} AND visits.id=responses.visit_id AND visits.locale IN ('#{code}', '#{exp_code}')) LEFT OUTER JOIN users ON (visits.user_id=users.id)",
        :group => "visits.locale",
        :conditions => "question_id=#{question.id} AND (users.state!='admin' OR users.state IS NULL)"
      ).inject([]) do |array2, count|
        array2 << [question.for_locale(count.first), count.last]
      end
    end
    @prompt_counts = questions.inject([]) do |array, question|
      array << Response.count(
        :joins => "INNER JOIN prompts ON (prompts.id=responses.prompt_id) INNER JOIN visits ON (visits.prompts_per_question IS NOT NULL AND visits.id=responses.visit_id) LEFT OUTER JOIN users ON (visits.user_id=users.id)",
        :group => "visits.prompts_per_question",
        :conditions => "question_id=#{question.id} AND (users.state!='admin' OR users.state IS NULL)"
      ).inject([]) do |array2, count|
        array2 << [question.groups.first.name, count.first, count.last]
      end
    end.reject { |el| el.empty? }
  end
end
