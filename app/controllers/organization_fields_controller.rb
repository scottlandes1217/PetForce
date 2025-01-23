class OrganizationFieldsController < ApplicationController
  before_action :set_organization

  def index
    @organization_fields = @organization.organization_fields.includes(icon_attachment: :blob)
  end

  def create
    @organization_field = @organization.organization_fields.new(organization_field_params)
    if @organization_field.save
      render json: {
        id: @organization_field.id,
        field_type: @organization_field.field_type,
        value: @organization_field.value,
        priority: @organization_field.priority,
        icon_url: @organization_field.icon.attached? ? url_for(@organization_field.icon) : nil
      }, status: :created
    else
      render json: { errors: @organization_field.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @organization_field = @organization.organization_fields.find(params[:id])
    if @organization_field.update(organization_field_params)
      render json: @organization_field, status: :ok
    else
      render json: { errors: @organization_field.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @organization_field = @organization.organization_fields.find(params[:id])
    @organization_field.destroy
    head :no_content
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def organization_field_params
    # Add :icon and :priority to the list of permitted parameters
    params.require(:organization_field).permit(:field_type, :value, :icon, :priority)
  end
end