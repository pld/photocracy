class Param < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :value

  class << self
    @@named_values = {}
    include Constants::Params

    def login_required?(page)
      boolean(LOGIN_REQUIRED[page])
    end

    def find_by_code(code)
      first(:conditions => { :name => LOGIN_REQUIRED[code.to_sym] || code })
    end

    def create_for_code(code, value)
      create(:name => LOGIN_REQUIRED[code.to_sym] || code, :value => value)
    end

    def random_first_question?
      boolean(RANDOM_FIRST_QUESTION)
    end

    def english_vary_percent
      p = first(:conditions => { :name => ENGLISH_VARY_PERCENT })
      p ? 100 - p.value.to_f : 0
    end

    def english_vary_prob
      english_vary_percent / 100.0
    end

    # store as integer equal to a rounded (float * 100)
    def random_new_question_percent
      p = first(:conditions => { :name => RANDOM_NEW_QUESTION_PERCENT })
      100 - (p && p.value).to_f
    end

    def refresh_question_after
      value_named(REFRESH_QUESTION_AFTER, Default::REFRESH_QUESTION_AFTER).to_i
    end

    def random_new_question_prob
      random_new_question_percent / 100.0
    end

    def comment_flags_for_suspend
      Param.value_named(COMMENT_FLAGS_FOR_SUSPEND, Default::COMMENT_FLAGS_FOR_SUSPEND).to_i
    end

    def item_flags_for_suspend
      Param.value_named(ITEM_FLAGS_FOR_SUSPEND, Default::ITEM_FLAGS_FOR_SUSPEND).to_i
    end

    # false if param exists and value is 'f', otherwise true
    def boolean(name)
      (p = first(:conditions => { :name => name })) ? p.value != 'f' : true
    end

    def value_named(name, default = nil)
      @@named_values[name] ||= (p = first(:conditions => { :name => name })) && p.value || default
    end

    def flag_question_image?
      boolean(FLAG_QUESTION_IMAGE)
    end

    def lock_spawn_fetch(visit_id)
      lock_spawn(Spawn::FETCH, visit_id)
    end

    def unlocked_spawn_fetch?(visit_id)
      unlocked_spawn?(Spawn::FETCH, visit_id)
    end

    def unlock_spawn_fetch(visit_id)
      unlock_spawn(Spawn::FETCH, visit_id)
    end

    def lock_spawn_graphs; lock_spawn(Spawn::GRAPH) end

    def unlocked_spawn_graphs?; unlocked_spawn?(Spawn::GRAPH) end

    def unlock_spawn_graphs; unlock_spawn(Spawn::GRAPH) end

    def data_store(name, value)
      record = first(:conditions => { :name => name })
      if record
        record.update_attribute(:value, YAML.dump(value))
      else
        create(:name => name, :value => value)
      end
    end

    def data_load(name)
      record = first(:conditions => { :name => name })
      (record && YAML.load(record.value)) || []
    end

  private
      def lock_spawn(name, scope = nil)
        name = "#{name}#{scope if scope}"
        lock = first(:conditions => { :name => name })
        if lock
          lock.update_attribute(:value, 'f')
        else
          create(:name => name, :value => 'f')
        end
      end

      def unlocked_spawn?(name, scope = nil)
        boolean("#{name}#{scope if scope}")
      end

      def unlock_spawn(name, scope = nil)
        find_by_name("#{name}#{scope if scope}").update_attribute(:value, 't')
      end
    end
end
