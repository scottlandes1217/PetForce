class Form < ApplicationRecord
  belongs_to :organization
  has_many :form_submissions, dependent: :destroy
  
  # Validations
  validates :name, presence: true
  validates :is_active, inclusion: { in: [true, false] }
  
  # Default values
  attribute :is_active, :boolean, default: true
  attribute :form_data, :json, default: {}
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  
  # Methods
  def to_s
    name
  end
  
  def form_html
    form_data['html'] || ''
  end
  
  def form_css
    form_data['css'] || ''
  end
  
  def form_js
    form_data['js'] || ''
  end
end
