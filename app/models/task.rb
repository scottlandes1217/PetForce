class Task < ApplicationRecord
    STATUSES = %w[Scheduled Pending On-Hold Overdue Completed].freeze
  
    belongs_to :pet
  
    validates :status, inclusion: { in: STATUSES }
    validates :subject, presence: true
    validates :duration_minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  
    before_save :update_status
  
    def update_status
      if completed_at.present?
        self.status = "Completed"
      elsif start_time.present? && duration_minutes.present?
        end_time = start_time + duration_minutes.minutes
        now = Time.current
  
        if status != "On-Hold"
          self.status =
            if start_time > now
              "Scheduled"
            elsif now.between?(start_time, end_time)
              "Pending"
            elsif end_time < now
              "Overdue"
            end
        end
      end
    end
  end