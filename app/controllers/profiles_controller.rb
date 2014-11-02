class ProfilesController < ApplicationController
  before_action :user

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Profile", :profile_path

  def edit
    add_breadcrumb "Edit", :edit_profile_path
  end

  def update
    if @user.update_attributes(user_params)
      flash[:notice] = "Profile was successfully updated"
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
    params.require(:user).permit(:name, :email, :bio, :avatar)
  end
end
