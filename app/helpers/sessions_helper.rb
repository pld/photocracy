module SessionsHelper
  def link_to_login_or_logout
    @logged_in ? link_to(t('users.logout'), logout_path, { :title => t('users.logout') }) : link_to(t('users.login'), login_path)
  end
end