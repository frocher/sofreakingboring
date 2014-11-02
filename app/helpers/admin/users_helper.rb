module Admin::UsersHelper
  def user_tags(user)
    tags = Array.new
    if user.admin?
      tags.push "admin"
    end
    # TODO : test if blocked
    tags.push "active"
  end
end
