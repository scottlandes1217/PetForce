class PinnedTabsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @pinned_tabs = current_user.pinned_tabs.ordered
    render json: @pinned_tabs
  end
  
  def create
    if params[:pet_id].present?
      pet = Pet.find(params[:pet_id])
      @pinned_tab = PinnedTab.pin_pet(current_user, pet)
      render json: { success: true, tab: @pinned_tab }
    else
      render json: { success: false, error: 'Invalid parameters' }, status: :unprocessable_entity
    end
  end
  
  def destroy
    @pinned_tab = current_user.pinned_tabs.find(params[:id])
    @pinned_tab.destroy
    render json: { success: true }
  end
  
  def unpin_pet
    pet = Pet.find(params[:pet_id])
    PinnedTab.unpin_pet(current_user, pet)
    render json: { success: true }
  end
end 