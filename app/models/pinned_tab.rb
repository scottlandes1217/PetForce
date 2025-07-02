class PinnedTab < ApplicationRecord
  belongs_to :user
  belongs_to :tabable, polymorphic: true
  
  validates :title, presence: true
  validates :url, presence: true
  validates :tab_type, presence: true
  
  scope :for_user, ->(user) { where(user: user) }
  scope :ordered, -> { order(created_at: :asc) }
  
  def self.pin_pet(user, pet)
    find_or_create_by(
      user: user,
      tabable: pet,
      tab_type: 'pet'
    ) do |tab|
      tab.title = pet.name
      tab.url = Rails.application.routes.url_helpers.organization_pet_path(pet.organization, pet)
    end
  end
  
  def self.unpin_pet(user, pet)
    where(user: user, tabable: pet, tab_type: 'pet').destroy_all
  end
end 