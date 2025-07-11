class Flow < ApplicationRecord
  belongs_to :organization
  has_many :flow_blocks, dependent: :destroy
  has_many :flow_connections, dependent: :destroy
  
  validates :name, presence: true
  validates :description, presence: true
  
  # Store flow configuration as JSON
  serialize :config, JSON
  
  # Flow statuses
  enum status: { draft: 0, active: 1, inactive: 2 }
  
  # Block types available in the flow
  BLOCK_TYPES = %w[screen update_record create_record decision assignment loop wait].freeze
  
  def blocks
    flow_blocks.order(:position)
  end
  
  def connections
    flow_connections.includes(:from_block, :to_block)
  end
  
  def to_json_schema
    {
      id: id,
      name: name,
      description: description,
      status: status,
      blocks: blocks.map(&:to_json_schema),
      connections: connections.map(&:to_json_schema)
    }
  end
  
  def execute(trigger_data = {})
    FlowExecutor.new(self).execute(trigger_data)
  end
end 