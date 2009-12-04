module Systems::Locale
  def set_locale
    I18n.locale = session[:locale]
  end

  def locale=(locale)
    session[:locale] = locale
  end

  def locale_from_location(visit = nil)
    visit ||= session[:visit]
    country_code = visit && visit.ip_country_code && visit.ip_country_code.downcase
    (country_code && Constants::Locales::COUNTRY_TO_LOCALE.keys.include?(country_code)) ? Constants::Locales::COUNTRY_TO_LOCALE[country_code] : Constants::Locales::DEFAULT
  end

  def assign_locale(visit = nil)
    # if the user has set a session locale save it to their profile
    if session[:locale]
      current_user.profile.update_attribute(:locale, session[:locale]) if current_user && current_user.profile
    else
      session[:locale] = locale_from_location(visit)
    end
    I18n.locale = self.locale = session[:locale]
  end

  def translations
    non_default_languages.merge('English Variation' => 'e2')
  end

  def non_default_languages
    langs = Constants::Locales::ALL.dup
    langs.delete(Constants::DEFAULT_LANGUAGE)
    langs
  end
end