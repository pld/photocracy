module Translatable
  def for_locale(locale, exp_locale = nil)
    locale = exp_locale if exp_locale
    if locale && locale != Constants::Locales::DEFAULT && translation = translations.find_by_locale(locale)
      translation.value
    else
      name
    end
  end
end