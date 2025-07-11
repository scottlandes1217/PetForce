class OrchestrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_orchestration, only: [:show, :edit, :update, :destroy, :builder, :execute]
  before_action :ensure_user_belongs_to_organization

  def index
    @orchestrations = @organization.orchestrations.order(created_at: :desc)
  end

  def show
    @orchestration_blocks = @orchestration.orchestration_blocks.order(:position_y, :position_x)
    @recent_executions = @orchestration.orchestration_executions.recent.limit(10)
  end

  def new
    @orchestration = @organization.orchestrations.build
  end

  def create
    @orchestration = @organization.orchestrations.build(orchestration_params)
    
    if @orchestration.save
      redirect_to builder_organization_orchestration_path(@organization, @orchestration), 
                  notice: 'Orchestration was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    Rails.logger.info "Update params: #{params.inspect}"
    Rails.logger.info "Orchestration params: #{orchestration_params.inspect}"
    
    begin
      if @orchestration.update(orchestration_params)
        respond_to do |format|
          format.html { 
            redirect_to organization_orchestration_path(@organization, @orchestration), 
                        notice: 'Orchestration was successfully updated.'
          }
          format.json { 
            render json: { success: true, message: 'Orchestration saved successfully' }
          }
        end
      else
        Rails.logger.error "Update errors: #{@orchestration.errors.full_messages}"
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { 
            render json: { success: false, errors: @orchestration.errors.full_messages }, 
                   status: :unprocessable_entity 
          }
        end
      end
    rescue => e
      Rails.logger.error "Update exception: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { 
          render json: { success: false, errors: [e.message] }, 
                 status: :unprocessable_entity 
        }
      end
    end
  end

  def destroy
    @orchestration.destroy
    redirect_to organization_orchestrations_path(@organization), 
                notice: 'Orchestration was successfully deleted.'
  end

  def builder
    # This will render the visual builder interface
  end

  def execute
    execution = @orchestration.orchestration_executions.create!(
      user: current_user,
      execution_type: 'manual',
      status: 'pending'
    )
    
    # TODO: Queue the execution job
    # OrchestrationExecutionJob.perform_later(execution.id)
    
    redirect_to organization_orchestration_path(@organization, @orchestration), 
                notice: 'Orchestration execution started.'
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_orchestration
    @orchestration = @organization.orchestrations.find(params[:id])
  end

  def ensure_user_belongs_to_organization
    # Admins have access to all organizations
    return if current_user.admin?
    
    # Check if user belongs to the current organization
    unless current_user.organizations.include?(@organization)
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def orchestration_params
    # Handle JSON parameters for layout and connections data
    permitted_params = params.require(:orchestration).permit(:name, :status)
    
    # Handle layout_data and connections_data as JSON
    if params[:orchestration][:layout_data].present?
      # Convert to JSON if it's a string, otherwise use as-is
      layout_data = params[:orchestration][:layout_data]
      begin
        if layout_data.is_a?(String)
          permitted_params[:layout_data] = JSON.parse(layout_data)
        elsif layout_data.is_a?(Array)
          # Convert array of ActionController::Parameters to array of hashes
          permitted_params[:layout_data] = layout_data.map do |item|
            item.is_a?(ActionController::Parameters) ? item.to_unsafe_h : item
          end
        else
          # Convert ActionController::Parameters to hash
          permitted_params[:layout_data] = layout_data.to_unsafe_h
        end
      rescue JSON::ParserError => e
        Rails.logger.error "Invalid JSON in layout_data: #{e.message}"
        permitted_params[:layout_data] = []
      end
    end
    
    if params[:orchestration][:connections_data].present?
      # Convert to JSON if it's a string, otherwise use as-is
      connections_data = params[:orchestration][:connections_data]
      begin
        if connections_data.is_a?(String)
          permitted_params[:connections_data] = JSON.parse(connections_data)
        elsif connections_data.is_a?(Array)
          # Convert array of ActionController::Parameters to array of hashes
          permitted_params[:connections_data] = connections_data.map do |item|
            item.is_a?(ActionController::Parameters) ? item.to_unsafe_h : item
          end
        else
          # Convert ActionController::Parameters to hash
          permitted_params[:connections_data] = connections_data.to_unsafe_h
        end
      rescue JSON::ParserError => e
        Rails.logger.error "Invalid JSON in connections_data: #{e.message}"
        permitted_params[:connections_data] = []
      end
    end
    
    permitted_params
  end
end 