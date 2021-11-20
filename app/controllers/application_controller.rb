class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :doorkeeper_authorize!

  respond_to :json

  def current_user
    if doorkeeper_token && doorkeeper_token.resource_owner_id
      @current_user ||= User.find_by(id: doorkeeper_token.resource_owner_id)
    end
  end

  protected

  def configure_permitted_parameters
    keys = [:email]
    devise_parameter_sanitizer.permit :sign_up, keys: keys
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
