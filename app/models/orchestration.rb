class Orchestration < ApplicationRecord
  belongs_to :organization
  has_many :orchestration_blocks, dependent: :destroy
  has_many :orchestration_executions, dependent: :destroy
  
  validates :name, presence: true
  # Store the visual layout and connections as JSON
  serialize :layout_data, coder: JSON
  serialize :connections_data, coder: JSON
  
  def active?
    status == 'active'
  end
  
  def draft?
    status == 'draft'
  end
end 