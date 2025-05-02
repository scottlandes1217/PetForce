class TaskStatusUpdateWorker
  include Sidekiq::Worker

  def perform(task_id)
    task = Task.find_by(id: task_id)
    return unless task

    Rails.logger.info "TaskStatusUpdateWorker: Processing task #{task_id}"
    task.update_status!
  end
end 