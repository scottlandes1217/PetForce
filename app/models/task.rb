class Task < ApplicationRecord
    include Sidekiq::Worker
    
    STATUSES = %w[Scheduled Pending On-Hold Overdue Completed].freeze
  
    belongs_to :pet
  
    validates :status, inclusion: { in: STATUSES }
    validates :subject, presence: true
    validates :duration_minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

    before_save :clean_flag_list
    after_save :schedule_status_update, if: :should_schedule_update?
    after_destroy :cancel_scheduled_job
    after_save :sync_flags_with_pet

    after_create do
      Rails.logger.info "Task #{id}: Created with status #{status}"
      Rails.logger.info "Task #{id}: Start time: #{start_time.in_time_zone}"
      Rails.logger.info "Task #{id}: Duration: #{duration_minutes} minutes"
    end

    def update_status!
      Rails.logger.info "Task #{id}: update_status! called"
      Rails.logger.info "Task #{id}: Current status: #{status}"
      
      return if status == 'Completed' || status == 'On-Hold'
      return unless start_time.present? && duration_minutes.present?

      end_time = start_time.in_time_zone + duration_minutes.minutes
      now = Time.current.in_time_zone

      Rails.logger.info "Task #{id}: Updating status"
      Rails.logger.info "Task #{id}: Current status: #{status}"
      Rails.logger.info "Task #{id}: Current time: #{now}"
      Rails.logger.info "Task #{id}: Start time: #{start_time.in_time_zone}"
      Rails.logger.info "Task #{id}: End time: #{end_time}"

      new_status = case status
                   when 'Scheduled'
                     if now >= start_time.in_time_zone
                       'Pending'
                     end
                   when 'Pending'
                     if now >= end_time
                       'Overdue'
                     end
                   end

      if new_status && new_status != status
        Rails.logger.info "Task #{id}: Changing status from #{status} to #{new_status}"
        update(status: new_status)
        
        # If we just changed to Pending, schedule the Overdue check
        if new_status == 'Pending'
          Rails.logger.info "Task #{id}: Scheduling Overdue check for #{end_time}"
          TaskStatusUpdateWorker.perform_at(end_time, id)
        end
      else
        Rails.logger.info "Task #{id}: No status change needed"
      end
    end

    private

    def clean_flag_list
      self.flag_list = flag_list.reject(&:blank?) if flag_list.present?
    end

    def sync_flags_with_pet
      return unless saved_change_to_status? || saved_change_to_flag_list?

      # Get the current flags for this task
      current_flags = flag_list || []

      # Check if we should add or remove flags
      if %w[Pending Overdue].include?(status)
        # Add flags to pet if they don't exist
        pet.flags = (pet.flags + current_flags).uniq
        Rails.logger.info "Task #{id}: Adding flags #{current_flags} to pet #{pet.id}"
      elsif %w[Completed On-Hold Scheduled].include?(status)
        # Remove flags from pet if no other tasks need them
        current_flags.each do |flag|
          # Only remove if no other active tasks have this flag
          unless pet.tasks.where.not(id: id)
                          .where(status: %w[Pending Overdue])
                          .where("flag_list @> ARRAY[?]::varchar[]", [flag])
                          .exists?
            pet.flags = pet.flags - [flag]
            Rails.logger.info "Task #{id}: Removing flag #{flag} from pet #{pet.id}"
          end
        end
      end

      # Save the pet if flags were changed
      if pet.changed?
        Rails.logger.info "Task #{id}: Saving pet #{pet.id} with flags #{pet.flags}"
        pet.save
      end
    end

    def should_schedule_update?
      Rails.logger.info "Task #{id}: Checking if should schedule update"
      Rails.logger.info "Task #{id}: Current status: #{status}"
      Rails.logger.info "Task #{id}: Start time: #{start_time.in_time_zone}"
      Rails.logger.info "Task #{id}: Duration: #{duration_minutes}"

      return false if status == 'Completed' || status == 'On-Hold'
      return false unless start_time.present? && duration_minutes.present?
      
      # Only schedule if the task is in the future or currently active
      end_time = start_time.in_time_zone + duration_minutes.minutes
      should_schedule = Time.current.in_time_zone <= end_time
      Rails.logger.info "Task #{id}: should_schedule_update? = #{should_schedule}"
      should_schedule
    end

    def schedule_status_update
      end_time = start_time.in_time_zone + duration_minutes.minutes
      now = Time.current.in_time_zone

      Rails.logger.info "Task #{id}: Scheduling status update"
      Rails.logger.info "Task #{id}: Current time: #{now}"
      Rails.logger.info "Task #{id}: Start time: #{start_time.in_time_zone}"
      Rails.logger.info "Task #{id}: End time: #{end_time}"
      Rails.logger.info "Task #{id}: Current status: #{status}"

      if now < start_time.in_time_zone
        # Task is in the future, schedule it to start
        Rails.logger.info "Task #{id}: Scheduling to start at #{start_time.in_time_zone}"
        TaskStatusUpdateWorker.perform_at(start_time.in_time_zone, id)
      elsif now < end_time
        # Task is currently active, schedule it to end
        Rails.logger.info "Task #{id}: Scheduling to end at #{end_time}"
        TaskStatusUpdateWorker.perform_at(end_time, id)
      else
        Rails.logger.info "Task #{id}: No scheduling needed - task is in the past"
      end
    end

    def cancel_scheduled_job
      # Cancel any pending jobs for this task
      Sidekiq::ScheduledSet.new.each do |job|
        job.delete if job.args.first&.dig('_aj_globalid')&.include?("Task/#{id}")
      end
    end
end