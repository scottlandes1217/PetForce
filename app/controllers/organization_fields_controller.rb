class OrganizationFieldsController < ApplicationController
  before_action :set_organization

  def index
    @organization_fields = @organization.organization_fields
  end

  def create
    @organization_field = @organization.organization_fields.new(organization_field_params)
    if @organization_field.save
      render json: @organization_field, status: :created
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
    params.require(:organization_field).permit(:field_type, :value)
  end
end