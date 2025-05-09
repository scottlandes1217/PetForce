class TasksController < ApplicationController
    before_action :set_organization
    before_action :set_pet
    before_action :set_task, only: %i[show edit update destroy]
  
    def index
      @tasks = @pet.tasks
    end
  
    def new
      @task = Task.new
      @organization = Organization.find(params[:organization_id])
      @pet = @organization.pets.find(params[:pet_id])
    end
  
    def show
      @task = Task.find(params[:id])
    end
  
    def create
      @task = @pet.tasks.build(task_params)
      if @task.save
        redirect_to organization_pet_path(@organization, @pet, tab: "tasks"), notice: "Task created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    def edit; end
  
    def update
      if @task.update(task_params)
        redirect_to organization_pet_path(@organization, @pet, tab: "tasks"), notice: "Task updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    def destroy
      @task.destroy
      redirect_to organization_pet_path(@organization, @pet, tab: "tasks"), notice: "Task deleted successfully."
    end
  
    private
  
    def set_organization
      @organization = Organization.find(params[:organization_id])
    end
  
    def set_pet
      @pet = @organization.pets.find(params[:pet_id])
    end
  
    def set_task
      @task = @pet.tasks.find(params[:id])
    end
  
    def task_params
      params.require(:task).permit(
        :status,
        :subject,
        :description,
        :start_time,
        :completed_at,
        :duration_minutes,
        :task_type_id,
        flag_list: []
      )
    end
  end