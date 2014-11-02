class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    handle_omniauth("Facebook", "devise.facebook_data")
  end

  def google_oauth2
    handle_omniauth("Google", "devise.google_data")
  end

  def github
    handle_omniauth("Github", "devise.github_data")
  end
private

  def handle_omniauth(kind, session_key)
    @user = User.from_omniauth(request.env["omniauth.auth"].except("extra"))

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
    else
      session[session_key] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

end