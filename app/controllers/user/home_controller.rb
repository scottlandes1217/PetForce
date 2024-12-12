module User
  class HomeController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_normal_user!

    def index
      # Fetch any normal user-specific data here (e.g., pets available for adoption, user profile, etc.)
    end

    private

    def authorize_normal_user!
      redirect_to root_path, alert: 'Not authorized' unless current_user.normal_user?
    end
  end
end