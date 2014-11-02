class Profiles::PasswordsController < ApplicationController
  before_action :user

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Profile", :profile_path

  def edit
    add_breadcrumb "Change password", :edit_profile_password_path
  end

  def update
    if @user.update_attributes(user_params)
      flash[:notice] = "Profile was successfully updated"
      sign_in(@user, :bypass => true)
      redirect_to profile_path
    else
      render "edit"
    end 
  end

  private

  def user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
