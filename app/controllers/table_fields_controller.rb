class TableFieldsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_table_type
  before_action :ensure_custom_table_exists

  def index
    @query = params[:query]
    
    # Get all custom fields for this table type
    @custom_fields = @custom_table.custom_fields.order(:display_name)
    
    # Get built-in fields for this table type (if any)
    @built_in_fields = get_built_in_fields
    
    # Combine all fields
    @all_fields = @custom_fields + @built_in_fields
    Rails.logger.info "Total fields: #{@all_fields.count} (Custom: #{@custom_fields.count}, Built-in: #{@built_in_fields.count})"
    
    # Apply search filter if query present
    if @query.present?
      @all_fields = @all_fields.select do |field|
        field.display_name.downcase.include?(@query.downcase) ||
        field.name.downcase.include?(@query.downcase) ||
        (field.respond_to?(:description) && field.description&.downcase&.include?(@query.downcase))
      end
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_table_type
    @table_type = params[:table_type]
    @table_display_name = @table_type.titleize
  end

  def ensure_custom_table_exists
    # Ensure the custom table exists for this table type
    table_config = case @table_type
    when 'pets'
      {
        name: 'pets',
        display_name: 'Pets',
        api_name: 'pets',
        description: 'Built-in table for managing pets',
        icon_type: 'font_awesome',
        font_awesome_icon: 'fas fa-paw',
        add_to_navigation: false
      }
    when 'tasks'
      {
        name: 'tasks',
        display_name: 'Tasks',
        api_name: 'tasks',
        description: 'Built-in table for managing tasks',
        icon_type: 'font_awesome',
        font_awesome_icon: 'fas fa-tasks',
        add_to_navigation: false
      }
    when 'events'
      {
        name: 'events',
        display_name: 'Events',
        api_name: 'events',
        description: 'Built-in table for managing events',
        icon_type: 'font_awesome',
        font_awesome_icon: 'fas fa-calendar',
        add_to_navigation: false
      }
    else
      # For custom tables, find the existing table
      @custom_table = @organization.custom_tables.find_by(api_name: @table_type)
      return if @custom_table
      
      redirect_to organization_tables_path(@organization), alert: "Table not found"
    end

    @custom_table = @organization.custom_tables.find_or_create_by(api_name: table_config[:api_name]) do |table|
      table.assign_attributes(table_config)
    end
  end

  def get_built_in_fields
    # Define built-in fields for each table type
    case @table_type
    when 'pets'
      [
        OpenStruct.new(
          id: 'name',
          name: 'name',
          display_name: 'Name',
          field_type: 'text',
          required: true,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Pet name',
          built_in: true
        ),
        OpenStruct.new(
          id: 'age',
          name: 'age',
          display_name: 'Age',
          field_type: 'number',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Pet age',
          built_in: true
        ),
        OpenStruct.new(
          id: 'description',
          name: 'description',
          display_name: 'Description',
          field_type: 'textarea',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Pet description',
          built_in: true
        ),
        OpenStruct.new(
          id: 'weight_lbs',
          name: 'weight_lbs',
          display_name: 'Weight (lbs)',
          field_type: 'number',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Pet weight in pounds',
          built_in: true
        ),
        OpenStruct.new(
          id: 'weight_oz',
          name: 'weight_oz',
          display_name: 'Weight (oz)',
          field_type: 'number',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Pet weight in ounces',
          built_in: true
        ),
        OpenStruct.new(
          id: 'date_of_birth',
          name: 'date_of_birth',
          display_name: 'Date of Birth',
          field_type: 'date',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Pet date of birth',
          built_in: true
        ),
        OpenStruct.new(
          id: 'entered_shelter',
          name: 'entered_shelter',
          display_name: 'Entered Shelter',
          field_type: 'date',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Date pet entered shelter',
          built_in: true
        ),
        OpenStruct.new(
          id: 'left_shelter',
          name: 'left_shelter',
          display_name: 'Left Shelter',
          field_type: 'date',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Date pet left shelter',
          built_in: true
        ),
        OpenStruct.new(
          id: 'microchip',
          name: 'microchip',
          display_name: 'Microchip',
          field_type: 'text',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Pet microchip number',
          built_in: true
        ),
        OpenStruct.new(
          id: 'dod',
          name: 'dod',
          display_name: 'Date of Death',
          field_type: 'date',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Pet date of death',
          built_in: true
        )
      ]
    when 'tasks'
      [
        OpenStruct.new(
          id: 'subject',
          name: 'subject',
          display_name: 'Subject',
          field_type: 'text',
          required: true,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Task subject',
          built_in: true
        ),
        OpenStruct.new(
          id: 'description',
          name: 'description',
          display_name: 'Description',
          field_type: 'textarea',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Task description',
          built_in: true
        ),
        OpenStruct.new(
          id: 'status',
          name: 'status',
          display_name: 'Status',
          field_type: 'picklist',
          required: true,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Task status',
          built_in: true
        ),
        OpenStruct.new(
          id: 'start_time',
          name: 'start_time',
          display_name: 'Start Time',
          field_type: 'datetime',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Task start time',
          built_in: true
        )
      ]
    when 'events'
      [
        OpenStruct.new(
          id: 'title',
          name: 'title',
          display_name: 'Title',
          field_type: 'text',
          required: true,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Event title',
          built_in: true
        ),
        OpenStruct.new(
          id: 'description',
          name: 'description',
          display_name: 'Description',
          field_type: 'textarea',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Event description',
          built_in: true
        ),
        OpenStruct.new(
          id: 'start_time',
          name: 'start_time',
          display_name: 'Start Time',
          field_type: 'datetime',
          required: true,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Event start time',
          built_in: true
        ),
        OpenStruct.new(
          id: 'end_time',
          name: 'end_time',
          display_name: 'End Time',
          field_type: 'datetime',
          required: false,
          unique: false,
          active: true,
          hidden: false,
          read_only: false,
          description: 'Event end time',
          built_in: true
        )
      ]
    else
      []
    end
  end


end
