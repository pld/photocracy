class Logger
  def block(text)
    info("\n########################\n\n")
    info(text)
    info("\n\n########################\n")
  end
end
class ActionView::Base
  alias old_pluralize pluralize
  def pluralize(count, string)
    (I18n.locale == I18n.default_locale) ? old_pluralize(count, string) : "#{count} #{string}"
  end
end