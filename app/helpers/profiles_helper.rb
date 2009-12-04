module ProfilesHelper
  def education
    format_question('edu', ['none', 'middle', 'high', 'college', 'grad'])
  end

  def gender
    format_question('gen', ['man', 'woman', 'other'])
  end

  def language
    format_question('lan', ['chinese_s', 'chinese_t', 'chinese_sh', 'chinese_ct', 'japanese', 'english', 'other'])
  end

  def location
    format_question('loc', ['work', 'home', 'school', 'other'])
  end

  def abroad
    format_question('abroad', ['none', 'little', 'medium', 'large'])
  end

  def profile_value(profile, name)
    if profile && !profile.new_record?
      q = profile.profile_questions.find_by_name(name)
      q && q.value
    elsif name == 'language'
      Constants::Locales::ALL.invert.fetch(I18n.locale)
    end
  end

  def country_from_code(code)
    found = COUNTRIES.find { |el| el.last == code }
    found && found.first
  end

  def profile_questions(sel_options)
    ['gender', 'language', 'education'].map do |el|
      sel_options[:selected] = profile_value(@profile, el)
      [el, select(:profile_question, el.to_sym, send(el), sel_options)]
    end + [
      # ['add_languages', "<p>#{text_area(:profile_question, :add_lang, :size => '40x2', :value => profile_value(@profile, 'add_lang'))}</p>"],
      # ['profession', text_field(:profile_question, :profession, :value => profile_value(@profile, 'profession'))],
      ['birth_country', country_select(:profile_question, :birth_country, Constants::Countries::PRIORITY, sel_options.merge(:selected => profile_value(@profile, 'birth_country')))]]
  end

  def country_select_with_guess(sel_options)
    options = unset_select?(sel_options) ? sel_options.merge(:selected => @controller.current_visit.ip_country_code) : sel_options
    country_select(:profile, :country, Constants::Countries::PRIORITY, options)
  end

  def date_select_with_guess(sel_options)
    options = unset_select?(sel_options) ? sel_options.merge(:selected => Time.now.year - 19) : sel_options
    date_select(:profile, :date_of_birth, {
        :discard_day => true,
        :discard_month => true,
        :start_year => Time.now.year,
        :end_year => 1900,
        :order => [:year],
      }.merge(options)
    )
  end

  private
    def format_question(category, options)
      options.map { |option| t("profile.#{category}_options.#{option}") }
    end

    def unset_select?(sel_options)
      (!@profile || @profile.new_record?) && sel_options[:selected].nil?
    end
end
