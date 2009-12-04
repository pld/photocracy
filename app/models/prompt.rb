class Prompt < ActiveRecord::Base
  belongs_to :question
  belongs_to :visit
  belongs_to :user
  has_and_belongs_to_many :items
  has_one :response

  validates_presence_of :prompt_id_ext
  validates_presence_of :question_id
  validates_presence_of :user_id

  validates_uniqueness_of :prompt_id_ext

  class << self
    include Constants::Prompts

    # return fetched prompt and boolean true if new external fetch needed
    def fetch(uid, ext_id, question, visit_id, prompts_shown)
      if uid == ANONYMOUS_USER_ID && prompts_shown < Param.value_named(PRIME_FOR, Default::PRIME_FOR).to_i
        # fetch a primed prompt
        fetch_first(uid, ext_id, visit_id, question, Param.value_named(PRIME_FOR, Default::PRIME_FOR).to_i, true)
      else
        fetch_first(uid, ext_id, visit_id, question, Param.refresh_question_after.to_i)
      end
    end

    def pairwise_fetch(question, ext_id, uid, visit_id, prompts_to_fetch = PROMPTS_PER_FETCH, prime = false)
      prompts, item_ids = Pairwise.prompt(question.question_id_ext, ext_id, prompts_to_fetch, prime)
      return false if prompts.to_a.empty?
      items = Item.all(:conditions => "item_id_ext IN (#{item_ids.flatten.join(',')})")
      items = item_ids.map { |el| el.map { |id| items.detect { |item| item.item_id_ext == id.to_i } } }
      prompt_to_return = nil
      Prompt.transaction do
        prompts.each do |id_ext|
          next if Prompt.exists?(:prompt_id_ext => id_ext)
          prompt = Prompt.create!(:prompt_id_ext => id_ext,
            :question_id => question.id,
            :user_id => uid,
            :visit_id => visit_id,
            :active => true
          )
          prompt.items << items.shift
          prompt_to_return = prompt if prompt_to_return.nil?
        end
      end
      prompt_to_return
    end

    def fetch_more?(user_id, visit_id, question_id)
      count(:conditions => active_conditions(user_id, visit_id, question_id)) < MIN_AVAILABLE_PROMPTS
    end

    private
      def active_conditions(user_id, visit_id, question_id)
        conditions = {
          'prompts.active' => true,
          'prompts.user_id' => user_id,
          'prompts.question_id' => question_id,
        }
        user_id == ANONYMOUS_USER_ID ? conditions.merge('prompts.visit_id' => visit_id) : conditions
      end

      def fetch_first(uid, ext_id, visit_id, question, prompts_to_fetch, primed = false)
        conditions = active_conditions(uid, visit_id, question.id)
        prompts = all(:conditions => conditions, :limit => MIN_AVAILABLE_PROMPTS)
        # if entirely out fetch more
        if prompts.empty?
          prompt = pairwise_fetch(question, ext_id, uid, visit_id, prompts_to_fetch, primed)
          # fetch next prompt now since must cache a prompt
          pairwise_fetch(question, ext_id, uid, visit_id, Param.refresh_question_after.to_i - prompts_to_fetch) if prompts_to_fetch < 2
        else
          prompt = prompts.first
        end
        prompt.update_attribute(:active, false) if prompt
        [prompt, prompts.length < MIN_AVAILABLE_PROMPTS]
      end
  end
end