class TablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def index
    @query = params[:query]
    
    # Define built-in tables
    built_in_tables = []
    
    # Ensure custom tables exist for built-in tables and get their IDs
    ['pets', 'tasks', 'events'].each do |table_type|
      custom_table = ensure_built_in_custom_table_exists(table_type)
      
      table_config = case table_type
      when 'pets'
        {
          name: 'pets',
          display_name: 'Pets',
          icon: 'fas fa-paw',
          description: 'Manage pets in your organization',
          record_count: @organization.pets.count,
          type: 'built_in',
          has_custom_fields: true,
          fields_path: organization_organization_table_fields_path(@organization, 'pets'),
          custom_table_id: 'pets',
          view_path: organization_custom_table_path(@organization, custom_table)
        }
      when 'tasks'
        {
          name: 'tasks',
          display_name: 'Tasks',
          icon: 'fas fa-tasks',
          description: 'Manage tasks and to-dos',
          record_count: @organization.tasks.count,
          type: 'built_in',
          has_custom_fields: true,
          fields_path: organization_organization_table_fields_path(@organization, 'tasks'),
          custom_table_id: 'tasks',
          view_path: organization_custom_table_path(@organization, custom_table)
        }
      when 'events'
        {
          name: 'events',
          display_name: 'Events',
          icon: 'fas fa-calendar',
          description: 'Manage calendar events',
          record_count: Event.where(organization: @organization).count,
          type: 'built_in',
          has_custom_fields: true,
          fields_path: organization_organization_table_fields_path(@organization, 'events'),
          custom_table_id: 'events',
          view_path: organization_custom_table_path(@organization, custom_table)
        }
      end
      
      built_in_tables << table_config
    end
    
    # Get custom tables (excluding built-in tables that were created as custom tables)
    built_in_api_names = ['pets', 'tasks', 'events']
    custom_tables = @organization.custom_tables.active.where.not(api_name: built_in_api_names).order(:display_name).map do |table|
      {
        name: table.api_name,
        display_name: table.display_name,
        icon: table.font_awesome_icon? ? table.font_awesome_icon : 'fas fa-database',
        path: organization_custom_table_path(@organization, table),
        description: table.description,
        record_count: table.custom_records.count,
        type: 'custom',
        has_custom_fields: true,
        custom_table: table,
        in_navigation: table.add_to_navigation?
      }
    end
    
    # Combine all tables
    @all_tables = built_in_tables + custom_tables
    
    # Apply search filter if query present
    if @query.present?
      @all_tables = @all_tables.select do |table|
        table[:display_name].downcase.include?(@query.downcase) ||
        table[:description].downcase.include?(@query.downcase)
      end
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def ensure_built_in_custom_table_exists(table_type)
    # Create the built-in custom table if it doesn't exist
    table_config = case table_type
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
    end

    @organization.custom_tables.find_or_create_by(api_name: table_config[:api_name]) do |table|
      table.assign_attributes(table_config)
    end
  end
end 