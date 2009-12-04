class Question < ActiveRecord::Base
  include Translatable

  has_and_belongs_to_many :groups

  has_many :items, :through => :items_questions
  has_many :items_questions
  has_many :translations, :as => :content

  validates_presence_of :name
  validates_presence_of :question_id_ext

  before_validation :remote, :if => lambda { |q| q.new_record? }


  def win_percents_overall
    ItemsQuestion.all({
      :conditions => { :question_id => id, :item_id => item_ids },
      :select => 'item_id, (100*CONVERT(wins, DECIMAL(13,10))/(wins + losses)) AS win_percent'
    }).inject({}) do |hash, el|
      hash[el.item_id] = el.win_percent.to_f || 0
      hash
    end
  end

  class << self
    def find_for_items(order = 'items_questions.position desc')
      # not joining looks cheaper
      # all(:include => { :items => [:items_questions, :questions, :attachment] }, :conditions => { 'items.active' => true }, :order => order)
      all(:include => [:items], :conditions => { 'items.active' => true }, :order => order)
    end

    def random(conditions = nil)
      questions = all(:conditions => conditions)
      questions[rand(questions.length)]
    end

    def fetch_new(cond)
      (Param.random_new_question_prob - rand > 0) ? random(cond) : for_locale_or_default(cond)
    end

    def fetch_first
      Param.random_first_question? ? random : for_locale_or_default
    end

    def for_locale_or_default(conditions = nil)
      group = Group.find_by_code(I18n.default_locale, :include => :questions, :conditions => conditions)
      (group && group.questions) ? group.questions[rand(group.questions.length)] : random(conditions)
    end
  end

  private
    def remote
      self.question_id_ext = Pairwise.question(name).first
    end
end
