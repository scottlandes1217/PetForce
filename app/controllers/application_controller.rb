class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_organization
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:role])
  end

  def after_sign_in_path_for(resource)
    case resource.role
    when 'admin'
      admin_home_path
    when 'shelter_staff'
      shelter_staff_home_path
    else
      user_home_path
    end
  end

  private

  def set_organization
    if session[:organization_id]
      @organization = Organization.find_by(id: session[:organization_id])
      unless @organization
        Rails.logger.debug "Invalid session[:organization_id]: #{session[:organization_id]}"
        session[:organization_id] = nil
      end
    end
    Rails.logger.debug "Session[:organization_id]: #{session[:organization_id]}"
    Rails.logger.debug "@organization: #{@organization.inspect}"
  end
end
