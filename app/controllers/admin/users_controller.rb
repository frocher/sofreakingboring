class Admin::UsersController < Admin::AdminController
  before_action :user, only: [:edit, :update, :destroy]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Users", :admin_users_path

  def index
    gon.user_id = current_user.id
    @users = User.order(:name).page(params[:page])
  end

  def new
    add_breadcrumb "New", :new_admin_user_path
    @user = User.new
  end

  def edit
    add_breadcrumb "Edit", :edit_admin_user_path
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "User was successfully created"
      redirect_to admin_users_path
    else
      render "new"
    end
  end

  def update
    if user_params[:password].blank?
      user_params.delete("password")
    end

    successfully_updated = if needs_password?(@user, params)
                             @user.update(user_params)
                           else
                             @user.update_without_password(user_params)
                           end

    if successfully_updated
      flash[:notice] = "User was successfully updated"
      redirect_to admin_users_path
    else
      render "edit"
    end
  end

  def destroy
    user.destroy
    redirect_to admin_users_path
  end

  def remove_avatar
    @user = User.find(params[:user_id])
    @user.avatar = nil
    @user.save
    flash[:notice] = "Avatar was successfully removed"
    redirect_to :back
  end

  protected

  def user
    @user = User.find(params[:id])
  end 

  def user_params
    params.require(:user).permit(:name, :email, :bio, :avatar, :password, :admin)
  end

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      params[:user][:password].present?
  end
end
