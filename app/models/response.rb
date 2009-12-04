class Response < ActiveRecord::Base
  belongs_to :prompt
  belongs_to :visit
  has_and_belongs_to_many :items

  validates_presence_of :visit_id
  validates_presence_of :prompt_id
  validates_presence_of :vote_id_ext
  validates_presence_of :response_time

  validates_uniqueness_of :prompt_id
  validates_uniqueness_of :vote_id_ext

  class << self
    include Constants::Responses

    def create_for_prompt(prompt, item_id_ext, voter_id_ext, options)
      vote_id_ext = Pairwise.vote(prompt.prompt_id_ext, item_id_ext, voter_id_ext, options[:response_time])
      create(options.merge(:vote_id_ext => vote_id_ext.first)) if vote_id_ext
    end

    def update_last_response(name, question_id)
      if last_res = Param.find_by_name("#{name}_#{question_id}")
        last_res.update_attribute(:value, last.id)
      else
        Param.create(:name => "#{name}_#{question_id}", :value => last.id)
      end if last
    end

    def refresh_response?(name, question_id)
      (last = Param.find_by_name("#{name}_#{question_id}")).nil? || count(:conditions => "responses.id > #{last.value}", :joins => "INNER JOIN prompts ON (responses.prompt_id=prompts.id AND prompts.question_id=#{question_id})") > UntilRank::RESPONSES
    end
  end
end
