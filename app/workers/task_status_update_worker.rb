class TaskStatusUpdateWorker
  include Sidekiq::Worker

  def perform(task_id)
    task = Task.find_by(id: task_id)
    return unless task

    Rails.logger.info "TaskStatusUpdateWorker: Processing task #{task_id}"
    task.update_status!

    # Broadcast the task status update
    Rails.logger.info "Broadcasting task status update for task #{task_id}"
    Turbo::StreamsChannel.broadcast_replace_to(
      "pet_#{task.pet_id}",
      target: "task_status_#{task.id}",
      partial: "tasks/task_status",
      locals: { task: task }
    )

    # Broadcast the pet header update to update flags
    Rails.logger.info "Broadcasting pet header update for pet #{task.pet_id}"
    Turbo::StreamsChannel.broadcast_replace_to(
      "pet_#{task.pet_id}",
      target: "pet_header",
      partial: "pets/pet_header",
      locals: { pet: task.pet }
    )
  end
end 