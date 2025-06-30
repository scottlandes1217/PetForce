class Organization < ApplicationRecord
    has_many :organization_users, dependent: :destroy
    has_many :users, through: :organization_users
    has_many :pets, dependent: :destroy
    has_many :organization_fields, dependent: :destroy
    has_many :posts
  
    validates :name, :street_address, :city, :state, :zip, :country, presence: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  end  