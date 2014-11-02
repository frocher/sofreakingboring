class Admin::AdminController < ApplicationController
  before_action :authenticate_admin!

  def authenticate_admin!
    return render_404 unless current_user.is_admin?
  end
end