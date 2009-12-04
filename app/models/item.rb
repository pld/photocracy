class Item < ActiveRecord::Base
  belongs_to :attachment
  belongs_to :visit
  has_and_belongs_to_many :prompts
  has_and_belongs_to_many :responses
  has_many :comments, :conditions => { :active => true }
  has_many :flags
  has_many :items_questions
  has_many :questions, :through => :items_questions
  has_one :flickr
  has_many :stats

  validates_inclusion_of :agree, :in => %w(1), :if => lambda { |i| i.new_record? }, :message => 'that you have rights to the photo.'
  validates_presence_of :item_id_ext, :if => lambda { |i| i.visit_id }
  validates_presence_of :visit_id, :if => lambda { |i| i.item_id_ext }
  validates_uniqueness_of :item_id_ext

  # ensure item inactive with pairwise before destroying
  before_destroy :suspend

  attr_accessor :agree

  acts_as_taggable_on :tags

  def question
    questions.first
  end

  def ratings(question_id, with_skips = false, joins = nil, conditions = {})
    if with_skips && joins.nil? && conditions.empty?
      items_questions.find_by_question_id(question_id).ratings
    elsif joins.nil? && conditions.empty?
      iq = items_questions.find_by_question_id(question_id)
      iq.wins + iq.losses
    else
      joins = "INNER JOIN prompts ON prompts.id=responses.prompt_id INNER JOIN items_prompts ON (items_prompts.prompt_id=prompts.id AND items_prompts.item_id=#{id}) #{joins}"
      joins = "INNER JOIN items_responses ON items_responses.response_id=responses.id #{joins}" unless with_skips
      Response.count(:joins => joins, :conditions => {
        :'prompts.question_id' => question_id,
        :'responses.active' => true
      }.merge(conditions))
    end
  end

  def ratings_for_country(country_code, question_id, with_skips = true)
    ratings(question_id, with_skips, nil, { 'responses.ip_country_code' => country_code })
  end

  def wins_for_country(country_code, question_id)
    wins(question_id, nil, { 'responses.ip_country_code' => country_code })
  end

  def wins(question_id, joins = nil, conditions = {})
    if joins.nil? && conditions.empty?
      items_questions.find_by_question_id(question_id).wins
    else
      joins = "INNER JOIN items_responses ON (items_responses.response_id=responses.id AND items_responses.item_id=#{id}) INNER JOIN prompts ON (responses.prompt_id=prompts.id AND prompts.question_id=#{question_id}) #{joins}"
      Response.count(:joins => joins, :conditions => { :'responses.active' => true }.merge(conditions))
    end
  end

  def win_percent(question_id = nil, with_skips = false, joins = nil, conditions = {})
    if question_id
      if joins.nil? && conditions.empty?
        if with_skips
          items_questions.first(:conditions => { :question_id => question_id }, :select => '100*(wins/ratings) AS win_percent').win_percent.to_f
        else
          items_questions.first(:conditions => { :question_id => question_id }, :select => '100*(wins/(wins+losses)) AS win_percent').win_percent.to_f
        end
      else
        ratings = ratings(question_id, with_skips, joins, conditions)
        ratings.zero? ? 0 : 100 * (wins(question_id, joins, conditions) / ratings.to_f)
      end
    else
      # for all questions
      questions.map { |q| win_percent(q.id, with_skips, joins) }.avg
    end
  end

  def win_percent_for_country(country_code, question_id = nil, with_skips = false)
    win_percent(question_id, with_skips, nil, { 'responses.ip_country_code' => country_code })
  end

  def position(question_id = nil)
    (question_id.nil? ? items_questions : items_questions.find_all_by_question_id(question_id)).avg(:position)
  end

  def suspend
    update_item_state(false)
    Prompt.update_all("active=0", "prompts.active=1 AND prompts.id IN (#{self.prompt_ids.join(',')})")
  end

  def activate
    # only allow activation of items with attachments
    update_item_state(true) unless self.attachment.nil?
  end

  def plot(for_questions = nil)
#    groups = Group.all(:select => 'code, name')
#    countries = groups.map(&:code)
#    country_names = groups.map(&:name)
#    (for_questions || questions).each do |question|
#      graph = Scruffy::Graph.new
#      graph.title = question.name.strip_tags
#      graph.renderer = Scruffy::Renderers::Standard.new
#      percents = countries.map { |country| win_percent_for_country(country, question.id).to_i }
#      percents.unshift(win_percent(question.id))
#      graph.add :bar, 'percent wins', percents
#      graph.render(
#        :min_value => 0,
#        :max_value => 100,
#        :size => [520, 300],
#        :to => "#{Constants::Config::Paths::PLOTS}question_#{question.id}_item_#{id}.png",
#        :as => 'png',
#        :point_markers => ['', 'All', '', 'China', '', 'Japan', '', 'US', '']
#      )
#    end
  end

  class << self
    include Constants::Item

    def per_page; PER_PAGE end

    def page_find(page = 1)
      paginate(:page => page || 1, :include => [:flags, :questions], :order => "items.created_at desc, flags.active desc")
    end

    def for_question(question, country_code, reject_under = REJECT_WITH_RATINGS_UNDER)
      not_by_country = country_code.to_s.empty?
      ratings = {}
      wins = {}
      percents = {}
      if not_by_country
        ratings = ratings_overall(question)
        wins = wins_overall(question)
        percents = wins.keys.inject({}) do |hash, key|
          rating = ratings[key]
          hash[key] = rating > 0 ? 100.0 * wins[key] / rating : 0
          hash
        end
      else
        group = Group.first(:conditions => "groups.code LIKE '#{country_code}'")
        result = ActiveRecord::Base.connection.execute(
          "SELECT item_id, ratings, wins, losses FROM stats WHERE question_id=#{question.id} AND group_id=#{group.id};"
        )
        stat = result.fetch_hash
        begin
          item_id = stat['item_id'].to_i
          ratings[item_id] = stat['ratings'].to_i
          wins[item_id] = win = stat['wins'].to_i
          percents[item_id] = [win, stat['losses'].to_i].to_percent
          stat = result.fetch_hash
        end while !stat.nil?
        result.free
      end
      pos = 0
      ranks = percents.sort_by do |percent|
        [-percent.last, -wins[percent.first]]
      end
      ranks = ranks.inject({}) do |hash, percent|
        hash[percent.first] = pos += 1
        hash
      end
      [wins, ratings, percents, ranks]
    end

    # if nil position or unaccounted response, refresh from pairwise
    def refresh_rank(question)
      if refresh_rank?(question.id)
          ids_ext_to_rank = (pairwise_rank(question) || return).to_hash
          ItemsQuestion.all(:conditions => { 'items_questions.question_id' => question.id, 'items.item_id_ext' => ids_ext_to_rank.keys, 'items.active' => true }, :include => :item).each do |iq|
            iq.update_attribute(:position, ids_ext_to_rank[iq.item.item_id_ext.to_i])
          end if ids_ext_to_rank.keys.length > 0
          Response.update_last_response(LAST_RANK_RESPONSE, question.id)
      end
    end

    def valid_objects(item, attachment, questions)
      # so validation is always run on item and attachment
      (item.valid? || attachment.valid?) && item.valid? && attachment.valid? && !questions.empty?
    end

    def new_remote(item, attachment, questions, visit_id)
      ext_id = Pairwise.item(item.description || DEFAULT_ITEM_NAME, questions)
      item.item_id_ext = ext_id.first
      item.visit_id = visit_id
      attachment.save
      item.attachment_id = attachment.id
      item.save
      item.questions << questions.map { |q| Question.find_by_question_id_ext(q) }
      item
    end

    def refresh_rank?(question_id)
      count(:conditions => { :active => true }, :joins => "INNER JOIN items_questions ON (question_id=#{question_id.to_i} AND item_id=items.id AND position IS NULL)") > Constants::Responses::UntilRank::ITEMS  || Response.refresh_response?(LAST_RANK_RESPONSE, question_id)
    end

    def by_win_percent(conditions)
      all({ :order => '(items_questions.wins/items_questions.ratings) desc',
        :group => 'items.id',
        :joins => 'INNER JOIN items_questions ON items_questions.item_id=items.id'
      }.merge(conditions))
    end

    def ratings_overall(question)
      ItemsQuestion.all(:conditions => { :question_id => question.id, :item_id => question.item_ids }, :select => 'item_id, (wins + losses) as ratings').inject({}) do |hash, el|
        hash[el.item_id] = el.ratings || 0
        hash
      end
    end

    def ratings_for_country(question, country = nil, with_skips = false)
      joins = "INNER JOIN prompts ON (prompts.id=responses.prompt_id AND prompts.question_id=#{question.id}) INNER JOIN items_prompts ON (items_prompts.prompt_id=prompts.id)"
      joins = "INNER JOIN items_responses ON items_responses.response_id=responses.id #{joins}" unless with_skips
      conditions = { :'responses.active' => true }
      conditions.merge!(:'responses.ip_country_code' => country) if country
      ratings = question.item_ids.inject({}) do |hash, id|
        hash[id] = 0
        hash
      end
      for response in Response.all({
        :select => "COUNT(*) AS ratings, items_prompts.item_id AS id",
        :conditions => conditions,
        :joins => joins,
        :group => 'items_prompts.item_id'
      }) do
        ratings[response.id.to_i] = response.ratings.to_i
      end
      ratings
    end

    def wins_overall(question)
      ItemsQuestion.all(:conditions => { :question_id => question.id, :item_id => question.item_ids }, :select => 'item_id, wins').inject({}) do |hash, el|
        hash[el.item_id] = el.wins || 0
        hash
      end
    end

    def wins_for_country(question, country = nil)
      joins = "INNER JOIN items_responses ON (items_responses.response_id=responses.id) INNER JOIN prompts ON (responses.prompt_id=prompts.id AND prompts.question_id=#{question.id})"
      conditions = {
        :'items_responses.item_id' => question.item_ids,
        :'responses.active' => true
      }
      conditions.merge!(:'responses.ip_country_code' => country) if country
      wins = question.item_ids.inject({}) do |hash, id|
        hash[id] = 0
        hash
      end
      for response in Response.all({
        :select => "COUNT(*) AS wins, items_responses.item_id AS id",
        :conditions => conditions,
        :joins => joins,
        :group => 'items_responses.item_id'
      }) do
        wins[response.id.to_i] = response.wins.to_i
        wins
      end
      wins
    end

    def win_percents_overall_array(question_id, item_ids)
      ItemsQuestion.all(
        :conditions => { :question_id => question_id, :item_id => item_ids },
        :select => '(100*CONVERT(wins, DECIMAL(13,10))/(wins + losses)) AS win_percent',
        :order => 'item_id'
      ).map { |el| el.win_percent.to_f || 0 }
    end

    def win_percents_overall(question_id, item_ids)
      ItemsQuestion.all(
        :conditions => { :question_id => question_id, :item_id => item_ids },
        :select => 'item_id, (100*CONVERT(wins, DECIMAL(13,10))/(wins + losses)) AS win_percent'
      ).inject({}) do |hash, el|
        hash[el.item_id.to_i] = el.win_percent.to_f || 0
        hash
      end
    end

    # def win_percents_for_country(question, country)
    #   wins = wins_for_country(question)
    #   ratings = ratings_for_country(question)
    #   question.items.inject({}) do |hash, item|
    #     rating = ratings[item.id]
    #     hash[item.id] = rating != 0 ? 100 * (wins[item.id].to_f / rating) : 0
    #     hash
    #   end
    # end
    # 
    # # in tests batching further than this causes inefficient joins
    # def win_percents_for_countries(question_id, items, countries, overall = false)
    #   percents = items.to_a.inject({}) do |hash, item|
    #     hash[item] = countries.map { |country| item.win_percent_for_country(country, question_id) }
    #     hash
    #   end
    #   if overall
    #     overall = win_percents_overall(question_id, items)
    #     percents.each { |key, value| percents[key] = value.unshift(overall[key.id]) }
    #   else
    #     percents
    #   end
    # end

private
    def pairwise_rank(question)
      Pairwise.list(:item, question.question_id_ext, RANK_ALGO_ID)
    end
  end

private
  def update_item_state(state)
    update_attribute(:active, state)
    Pairwise.update_item_state(item_id_ext, state)
  end
end
