class CustomRecordsController < ApplicationController
  before_action :set_organization
  before_action :set_custom_table
  before_action :set_custom_record, only: [:show, :edit, :update, :destroy]

  def index
    @custom_records = @custom_table.custom_records.includes(:custom_field_values).order(:name)
  end

  def show
    @custom_fields = @custom_table.custom_fields.active.visible.order(:name)
  end

  def new
    @custom_record = @custom_table.custom_records.build
    @custom_fields = @custom_table.custom_fields.active.visible.order(:name)
  end

  def create
    @custom_record = @custom_table.custom_records.build(custom_record_params)
    
    if @custom_record.save
      # Set field values
      set_field_values
      
      redirect_to organization_custom_table_custom_record_path(@organization, @custom_table, @custom_record), 
                  notice: 'Record was successfully created.'
    else
      @custom_fields = @custom_table.custom_fields.active.visible.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @custom_fields = @custom_table.custom_fields.active.visible.order(:name)
  end

  def update
    if @custom_record.update(custom_record_params)
      # Update field values
      update_field_values
      
      redirect_to organization_custom_table_custom_record_path(@organization, @custom_table, @custom_record), 
                  notice: 'Record was successfully updated.'
    else
      @custom_fields = @custom_table.custom_fields.active.visible.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @custom_record.destroy
    redirect_to organization_custom_table_custom_records_path(@organization, @custom_table), 
                notice: 'Record was successfully deleted.'
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_custom_table
    @custom_table = @organization.custom_tables.find(params[:custom_table_id])
  end

  def set_custom_record
    @custom_record = @custom_table.custom_records.find(params[:id])
  end

  def custom_record_params
    params.require(:custom_record).permit(:name, :external_id, :description)
  end

  def set_field_values
    return unless params[:field_values]

    params[:field_values].each do |field_api_name, value|
      @custom_record.set_field_value(field_api_name, value)
    end
  end

  def update_field_values
    return unless params[:field_values]

    params[:field_values].each do |field_api_name, value|
      @custom_record.set_field_value(field_api_name, value)
    end
  end
end 