class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  ROLES = %w[admin shelter_staff normal_user].freeze

  has_many :organization_users, dependent: :destroy
  has_many :organizations, through: :organization_users
  has_many :posts, dependent: :destroy
  has_many :reactions, dependent: :destroy

  validates :role, presence: true, inclusion: { in: ROLES }
  validate :ensure_shelter_staff_has_organizations

  def admin?
    role == 'admin'
  end

  def shelter_staff?
    role == 'shelter_staff'
  end

  def normal_user?
    role == 'normal_user'
  end

  private

  def ensure_shelter_staff_has_organizations
    if shelter_staff? && organizations.empty?
      errors.add(:organizations, 'must be assigned for shelter staff')
    end

    if admin? && organizations.exists?
      errors.add(:organizations, 'cannot be assigned for admin users')
    end
  end
end
