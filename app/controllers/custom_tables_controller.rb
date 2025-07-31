class CustomTablesController < ApplicationController
  before_action :set_organization
  before_action :set_custom_table, only: [:show, :edit, :update, :destroy]

  def index
    @custom_tables = @organization.custom_tables.includes(:custom_fields).order(:name)
  end

  def show
    @custom_fields = @custom_table.custom_fields.order(:name)
    @custom_records = @custom_table.custom_records.includes(:custom_field_values).order(:name)
  end

  def new
    @custom_table = @organization.custom_tables.build
  end

  def create
    @custom_table = @organization.custom_tables.build(custom_table_params)
    
    # Handle icon type based on selection
    if params[:custom_table][:font_awesome_icon] == 'custom'
      @custom_table.icon_type = 'uploaded'
      @custom_table.font_awesome_icon = 'fas fa-database' # fallback
    else
      @custom_table.icon_type = 'font_awesome'
    end
    
    if @custom_table.save
      redirect_to organization_custom_table_path(@organization, @custom_table), 
                  notice: 'Custom table was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Handle icon type based on selection
    if params[:custom_table][:font_awesome_icon] == 'custom'
      @custom_table.icon_type = 'uploaded'
      @custom_table.font_awesome_icon = 'fas fa-database' # fallback
    else
      @custom_table.icon_type = 'font_awesome'
    end
    
    if @custom_table.update(custom_table_params)
      redirect_to organization_custom_table_path(@organization, @custom_table), 
                  notice: 'Custom table was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @custom_table.destroy
    redirect_to organization_custom_tables_path(@organization), 
                notice: 'Custom table was successfully deleted.'
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_custom_table
    @custom_table = @organization.custom_tables.find(params[:id])
  end

  def custom_table_params
    params.require(:custom_table).permit(:name, :display_name, :api_name, :active, :description, :icon, :icon_type, :font_awesome_icon, :add_to_navigation)
  end
end 