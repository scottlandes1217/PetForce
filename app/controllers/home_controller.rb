class HomeController < ApplicationController
  before_action :authenticate_user! # Forces users to sign in before accessing the root page
  before_action :redirect_authenticated_user, if: :user_signed_in?

  def index
    # This action won't display anything since it redirects authenticated users.
    # Unauthenticated users will be redirected to the login page by `authenticate_user!`.
  end

  private

  # Redirect authenticated users to their role-specific home page
  def redirect_authenticated_user
    case current_user.role
    when 'admin'
      redirect_to admin_home_path
    when 'shelter_staff'
      redirect_to shelter_staff_home_path
    when 'normal_user'
      redirect_to user_home_path
    else
      sign_out current_user
      redirect_to new_user_session_path, alert: 'Invalid role. Please contact support.'
    end
  end
end