module HomeHelper
  def link_to_contact_email
    link_to(Constants::Urls::EMAIL, "mailto:#{Constants::Urls::EMAIL}")
  end
end
