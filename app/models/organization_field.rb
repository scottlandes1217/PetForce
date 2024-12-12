class OrganizationField < ApplicationRecord
  belongs_to :organization

  # Define field types as an enum for clarity and validation
  enum field_type: {
    species: 0,
    breed: 1,
    color: 2,
    unit: 3,
    location: 4,
    flags: 5
  }

  validates :field_type, presence: true
  validates :value, presence: true, uniqueness: { scope: [:organization_id, :field_type] }
end