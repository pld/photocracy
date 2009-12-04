class Mailer < ActionMailer::Base
  include Constants::Urls

  # def signup_notification(user)
  #   setup(user)
  #   @body[:url]  = "#{BASE}activate/#{user.activation_code}"
  # end
  #

  def reset_password(mailing, activation_code)
    setup(mailing)
    @subject += 'Your password has been reset'
    @body[:url]  = "#{BASE}reset/#{activation_code}"
  end

#  def activation(mailing)
#   setup(mailing)
#   @subject += 'Your account has been activated!'
#   @body[:url]  = BASE
#  end

  def item(mailing)
    setup(mailing)
    @subject += "#{mailing.user.login} sent you a photo"
    @body[:url] = "#{BASE}items/#{mailing.item_id}"
  end

  def share(mailing)
    setup(mailing)
  end

  def feedback(mailing)
    setup(mailing)
    @from = @recipients
    @recipients = EMAIL
    @body[:visit] = mailing.visit
  end

  def flagged(flag)
    set_attributes
    @recipients = "info@photocracy.org"
    if flag.item_id
      subj = "Item #{flag.item_id}"
    else
      subj = "Comment #{flag.comment_id}"
    end
    @subject += "Flagged: #{subj}"
    @body[:flag] = flag
    @body[:visit] = flag.visit
  end

  protected
    def setup(mailing)
      set_attributes
      @recipients  = "#{mailing.email}"
      @body[:mailing] = mailing
    end

    def set_attributes
      content_type "text/html"
      @from        = 'info@photocracy.org'
      @subject = "[Photocracy.org] "
      @content_type = "text/html"
      @sent_on = Time.now
    end

end
