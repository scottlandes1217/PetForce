class PetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_pet, only: [:show, :edit, :update, :destroy, :gallery]
  before_action :authorize_staff_or_admin!, except: [:index, :show]

  def index
    @query = params[:query]
    @pets = if @query.present?
              @organization.pets.where("name ILIKE :query OR breed ILIKE :query OR description ILIKE :query", query: "%#{@query}%")
            else
              @organization.pets
            end
    @pets = @pets.order(:name).page(params[:page]).per(10)
  end

  def show
    @posts = @pet.posts.includes(images_attachments: :blob) # Ensure images are loaded with posts
  end

  def new
    @pet = @organization.pets.build
  end

  def create
    @pet = @organization.pets.build(pet_params)

    if @pet.save
      respond_to do |format|
        format.html { redirect_to organization_pets_path(@organization), notice: 'Pet was successfully added.' }
        format.json { render json: { message: 'Pet was successfully added.', pet: @pet }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { error: 'Failed to create pet', errors: @pet.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    Rails.logger.info "Editing pet for organization: #{@organization.inspect}"
    Rails.logger.info "Pet being edited: #{@pet.inspect}"
  end

  def update
    Rails.logger.info "Params received for update: #{params.inspect}"
  
    # Handle photo upload
    if params[:pet] && params[:pet][:photo]
      uploaded_photo = params[:pet][:photo]
      @pet.photo.attach(uploaded_photo)
  
      # Also add to the gallery
      @pet.gallery_photos.attach(uploaded_photo)
  
      if @pet.photo.attached?
        render json: { photo_url: url_for(@pet.photo), success_message: "Photo updated successfully!" }, status: :ok
      else
        render json: { error: "Failed to attach photo" }, status: :unprocessable_entity
      end
      return
    end
  
    # Handle gallery image selection
    if params[:gallery_image_id]
      gallery_photo = ActiveStorage::Blob.find_signed(params[:gallery_image_id]) rescue nil
      if gallery_photo
        @pet.photo.attach(gallery_photo)
        render json: { photo_url: url_for(@pet.photo), success_message: "Photo updated successfully!" }, status: :ok
      else
        render json: { error: "Invalid gallery image" }, status: :unprocessable_entity
      end
      return
    end
  
    # Handle other updates (for fields like dob_estimated, species, breed, etc.)
    if @pet.update(pet_params)
      Rails.logger.info "Pet updated successfully: #{@pet.inspect}"
      respond_to do |format|
        format.html { redirect_to organization_pet_path(@organization, @pet), notice: 'Pet was successfully updated.' }
        format.json { render json: { success_message: "Pet updated successfully!" }, status: :ok }
      end
    else
      Rails.logger.error "Failed to update pet: #{@pet.errors.full_messages}"
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { error: @pet.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @pet.destroy
    Rails.logger.info "Pet deleted successfully: #{@pet.inspect}"
    respond_to do |format|
      format.html { redirect_to organization_pets_path(@organization), notice: 'Pet was successfully deleted.' }
      format.json { render json: { message: 'Pet was successfully deleted.' }, status: :ok }
    end
  end

  def gallery
    if request.post? # Handle photo uploads
      if params[:pet] && params[:pet][:gallery_photos]
        uploaded_photos = []
        params[:pet][:gallery_photos].each do |photo|
          uploaded_photo = @pet.gallery_photos.attach(photo)
          uploaded_photos << url_for(uploaded_photo.last) if uploaded_photo.present?
        end
  
        render json: {
          message: "Photos uploaded successfully.",
          uploaded_photos: uploaded_photos
        }, status: :ok
      else
        render json: { error: "No photos were selected." }, status: :unprocessable_entity
      end
    elsif request.delete? # Handle photo deletion
      photo = @pet.gallery_photos.find_by(id: params[:photo_id])
      if photo
        photo.purge
        render json: { message: "Photo removed successfully" }, status: :ok
      else
        render json: { error: "Photo not found" }, status: :unprocessable_entity
      end
    end
  end   

  private

  def pet_params
    params.require(:pet).permit(
      :name,
      :age,
      :description,
      :sex,
      :weight_lbs,
      :weight_oz,
      :date_of_birth,
      :entered_shelter,
      :left_shelter,
      :microchip,
      :dod,
      :species_id,
      :unit_id,
      :location_id,
      :mother_id,
      :father_id,
      :photo,
      :coat_type,
      gallery_photos: [],
      breed: [],
      color: [],
      flags: [],
      size: []
    ).tap do |whitelisted|
      whitelisted[:dob_estimated] = params[:pet][:dob_estimated].present? ? true : false
      whitelisted[:breed] = Array(params[:pet][:breed]) # Force breed to be an array
      whitelisted[:color] = Array(params[:pet][:color]) # Force color to be an array
      whitelisted[:flags] = Array(params[:pet][:flags]) # Force flags to be an array
    end
  end
  
  def set_organization
    Rails.logger.info "Finding organization with ID: #{params[:organization_id]}"
    @organization = Organization.find_by(id: params[:organization_id])
    unless @organization
      Rails.logger.error "Organization not found"
      redirect_to root_path, alert: "Organization not found"
    end
  end

  def set_pet
    Rails.logger.info "Finding pet with ID: #{params[:id]} for organization ID: #{params[:organization_id]}"
    @pet = @organization.pets.find_by(id: params[:id])
    unless @pet
      Rails.logger.error "Pet not found"
      redirect_to organization_pets_path(@organization), alert: "Pet not found"
    end
  end

  def authorize_staff_or_admin!
    unless current_user.admin? || (current_user.shelter_staff? && current_user.organizations.include?(@organization))
      Rails.logger.error "User not authorized: #{current_user.inspect}"
      redirect_to root_path, alert: 'Not authorized to perform this action.'
    end
  end
end