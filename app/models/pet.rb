class Pet < ApplicationRecord
  belongs_to :organization
  has_one_attached :photo
  validates :name, :breed, :age, presence: true
  has_many :posts, dependent: :destroy
  has_many_attached :gallery_photos
end