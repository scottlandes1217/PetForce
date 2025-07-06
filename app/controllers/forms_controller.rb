class FormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_form, only: [:show, :edit, :update, :destroy, :builder, :display, :submit]
  before_action :authorize_access!, except: [:display, :submit]

  def index
    @forms = @organization.forms.order(:name)
  end

  def show
  end

  def new
    @form = @organization.forms.build
  end

  def create
    @form = @organization.forms.build(form_params)
    
    if @form.save
      redirect_to organization_forms_path(@organization), notice: 'Form was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @form.update(form_params)
      respond_to do |format|
        format.html { redirect_to organization_forms_path(@organization), notice: 'Form was successfully updated.' }
        format.json { render json: { success: true, message: 'Form saved successfully' } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @form.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @form.destroy
    redirect_to organization_forms_path(@organization), notice: 'Form was successfully deleted.'
  end

  def builder
    # This will render the GrapeJS form builder
  end

  def display
    # Display the form for users to fill out
    unless @form.is_active?
      redirect_to root_path, alert: 'This form is not available.'
    end
  end

  def submit
    # Handle form submission
    unless @form.is_active?
      redirect_to root_path, alert: 'This form is not available.'
      return
    end

    submission = @form.form_submissions.build(data: params[:form_data])
    
    if submission.save
      redirect_to display_organization_form_path(@organization, @form), notice: 'Form submitted successfully!'
    else
      redirect_to display_organization_form_path(@organization, @form), alert: 'Error submitting form.'
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_form
    @form = @organization.forms.find(params[:id])
  end

  def form_params
    params.require(:form).permit(:name, :description, :is_active, form_data: {})
  end

  def authorize_access!
    unless current_user.admin? || 
           (current_user.shelter_staff? && current_user.organizations.include?(@organization))
      redirect_to root_path, alert: 'Not authorized'
    end
  end
end
