class UsersController < ApplicationController
  def avatar
    @user = User.find(params[:id])
    @size = params[:size].to_i

    url = view_context.avatar_icon(@user.email, @size)
    data = open(url).read
    send_data data, disposition: 'inline'
  end
end