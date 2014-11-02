class Profiles::AvatarsController < ApplicationController
  def destroy
    @user = current_user
    @user.avatar = nil
    @user.save

    redirect_to :back
  end
end
