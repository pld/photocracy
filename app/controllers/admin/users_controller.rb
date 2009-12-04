class Admin::UsersController < Admin::BaseController
  before_filter :find_user, :except => [:index, :paginate, :show]

  def index
    @users = User.page_find
  end

  def show
    @user = User.find(params[:id], :include => :visits)
  end

  def admin
    @user.admin!
    redirect_to admin_users_path
  end

  def active
    @user.activate!
    redirect_to admin_users_path
  end

  def suspend
    @user.suspend!
    redirect_to admin_users_path
  end

  def unsuspend
    @user.unsuspend!
    redirect_to admin_users_path
  end

  def destroy
    @user.delete!
    redirect_to admin_users_path
  rescue AASM::InvalidTransition
    redirect_to admin_users_path
  end

  def purge
    @user.destroy
    redirect_to admin_users_path
  end

protected
  def find_user
    @user = User.find(params[:id])
  end
end