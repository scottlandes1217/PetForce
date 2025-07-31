class CustomFieldsController < ApplicationController
  before_action :set_organization
  before_action :set_custom_table
  before_action :set_custom_field, only: [:show, :edit, :update, :destroy]

  def index
    @custom_fields = @custom_table.custom_fields.order(:name)
  end

  def show
  end

  def new
    @custom_field = @custom_table.custom_fields.build
  end

  def create
    @custom_field = @custom_table.custom_fields.build(custom_field_params)
    
    if @custom_field.save
      redirect_to organization_custom_table_custom_fields_path(@organization, @custom_table), 
                  notice: 'Custom field was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @custom_field.update(custom_field_params)
      redirect_to organization_custom_table_custom_fields_path(@organization, @custom_table), 
                  notice: 'Custom field was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @custom_field.destroy
    redirect_to organization_custom_table_custom_fields_path(@organization, @custom_table), 
                notice: 'Custom field was successfully deleted.'
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_custom_table
    @custom_table = @organization.custom_tables.find(params[:custom_table_id])
  end

  def set_custom_field
    @custom_field = @custom_table.custom_fields.find(params[:id])
  end

  def custom_field_params
    params.require(:custom_field).permit(
      :name, :display_name, :api_name, :field_type, :required, :unique, 
      :active, :hidden, :read_only, :description, :formula, :lookup_table_id,
      picklist_values: []
    )
  end
end 