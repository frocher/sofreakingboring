require 'gon'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :add_abilities
  before_action :add_gon_variables

  helper_method :abilities, :can?


  rescue_from ActiveRecord::RecordNotFound do |exception|
    render "errors/not_found", layout:"application", status: 404
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def abilities
    @abilities ||= Six.new
  end

  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end

  def add_abilities
    abilities << Ability
  end

  def render_403
    head :forbidden
  end

  def render_404
    render "errors/not_found", layout:"application", status: 404
  end

  def add_gon_variables
    gon.api_version = API::API.version
    gon.api_token = current_user.private_token if current_user
  end
end
