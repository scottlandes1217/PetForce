class CustomField < ApplicationRecord
  belongs_to :custom_table
  has_many :custom_field_values, dependent: :destroy

  # Field types similar to Salesforce
  enum field_type: {
    text: 0,
    textarea: 1,
    number: 2,
    date: 3,
    datetime: 4,
    checkbox: 5,
    picklist: 6,
    multipicklist: 7,
    email: 8,
    phone: 9,
    url: 10,
    currency: 11,
    percent: 12,
    lookup: 13,
    formula: 14,
    rollup: 15
  }

  validates :name, presence: true, uniqueness: { scope: :custom_table_id }
  validates :display_name, presence: true
  validates :api_name, presence: true, uniqueness: { scope: :custom_table_id }, format: { with: /\A[a-zA-Z][a-zA-Z0-9_]*\z/, message: "must start with a letter and contain only letters, numbers, and underscores" }
  validates :field_type, presence: true
  validates :required, inclusion: { in: [true, false] }
  validates :unique, inclusion: { in: [true, false] }
  
  # For picklist fields
  validates :picklist_values, presence: true, if: :picklist?
  validates :picklist_values, absence: true, unless: :picklist?
  
  # For formula fields
  validates :formula, presence: true, if: :formula?
  validates :formula, absence: true, unless: :formula?
  
  # For lookup fields
  validates :lookup_table_id, presence: true, if: :lookup?
  validates :lookup_table_id, absence: true, unless: :lookup?

  before_validation :generate_api_name, on: :create
  before_validation :ensure_api_name_format
  before_validation :set_defaults

  scope :active, -> { where(active: true) }
  scope :visible, -> { where(hidden: false) }

  # Serialize picklist values as JSON
  serialize :picklist_values, coder: JSON

  private

  def generate_api_name
    return if api_name.present?
    
    base_name = name.parameterize.underscore
    counter = 1
    generated_name = base_name
    
    while self.class.exists?(api_name: generated_name, custom_table_id: custom_table_id)
      generated_name = "#{base_name}_#{counter}"
      counter += 1
    end
    
    self.api_name = generated_name
  end

  def ensure_api_name_format
    return unless api_name.present?
    
    # Ensure it starts with a letter and contains only valid characters
    self.api_name = api_name.gsub(/[^a-zA-Z0-9_]/, '_')
    self.api_name = "field_#{api_name}" unless api_name.match?(/\A[a-zA-Z]/)
  end

  def set_defaults
    self.required ||= false
    self.unique ||= false
    self.active ||= true
    self.hidden ||= false
    self.read_only ||= false
  end

  def picklist?
    picklist? || multipicklist?
  end

  def formula?
    formula? || rollup?
  end

  def lookup?
    lookup?
  end
end 