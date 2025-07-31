class ConvertOrganizationFieldsToCustomFields < ActiveRecord::Migration[7.1]
  def up
    # First, ensure we have custom tables for built-in types
    Organization.find_each do |organization|
      # Create custom table for pets if it doesn't exist
      pets_table = organization.custom_tables.find_or_create_by(api_name: 'pets') do |table|
        table.name = 'pets'
        table.display_name = 'Pets'
        table.description = 'Built-in table for managing pets'
        table.icon_type = 'font_awesome'
        table.font_awesome_icon = 'fas fa-paw'
        table.add_to_navigation = false
      end

      # Create custom table for tasks if it doesn't exist
      tasks_table = organization.custom_tables.find_or_create_by(api_name: 'tasks') do |table|
        table.name = 'tasks'
        table.display_name = 'Tasks'
        table.description = 'Built-in table for managing tasks'
        table.icon_type = 'font_awesome'
        table.font_awesome_icon = 'fas fa-tasks'
        table.add_to_navigation = false
      end

      # Convert organization fields to custom fields
      organization.organization_fields.find_each do |org_field|
        case org_field.field_type
        when 'species', 'breed', 'color', 'flags'
          # These are pet-related fields
          custom_field = organization.custom_fields.find_or_create_by(
            custom_table: pets_table,
            api_name: "pet_#{org_field.field_type}_field"
          ) do |field|
            field.name = "#{org_field.field_type.titleize} Field"
            field.display_name = "#{org_field.field_type.titleize} Options"
            field.field_type = 'picklist'
            field.required = false
            field.unique = false
            field.active = true
            field.hidden = false
            field.read_only = false
            field.description = "Organization-defined #{org_field.field_type} options for pets"
            field.picklist_values = [org_field.value]
          end

          # If the custom field already exists, add the value to its picklist
          if custom_field.persisted? && !custom_field.picklist_values.include?(org_field.value)
            custom_field.picklist_values << org_field.value
            custom_field.save!
          end

        when 'unit', 'location'
          # These are task-related fields
          custom_field = organization.custom_fields.find_or_create_by(
            custom_table: tasks_table,
            api_name: "task_#{org_field.field_type}_field"
          ) do |field|
            field.name = "#{org_field.field_type.titleize} Field"
            field.display_name = "#{org_field.field_type.titleize} Options"
            field.field_type = 'picklist'
            field.required = false
            field.unique = false
            field.active = true
            field.hidden = false
            field.read_only = false
            field.description = "Organization-defined #{org_field.field_type} options for tasks"
            field.picklist_values = [org_field.value]
          end

          # If the custom field already exists, add the value to its picklist
          if custom_field.persisted? && !custom_field.picklist_values.include?(org_field.value)
            custom_field.picklist_values << org_field.value
            custom_field.save!
          end
        end
      end
    end

    # Remove the organization_fields table
    drop_table :organization_fields
  end

  def down
    # Recreate the organization_fields table
    create_table :organization_fields do |t|
      t.references :organization, null: false, foreign_key: true
      t.integer :field_type
      t.string :value
      t.string :icon
      t.integer :priority
      t.timestamps
    end

    # Convert custom fields back to organization fields (simplified)
    Organization.find_each do |organization|
      organization.custom_fields.where(field_type: 'picklist').find_each do |custom_field|
        # Extract field type from API name (e.g., "pet_species_field" -> "species")
        field_type = custom_field.api_name.match(/(pet|task)_(.+)_field/)&.[](2)
        
        if field_type && ['species', 'breed', 'color', 'flags', 'unit', 'location'].include?(field_type)
          # Create organization field for each picklist value
          custom_field.picklist_values.each do |value|
            organization.organization_fields.create!(
              field_type: field_type,
              value: value
            )
          end
        end
      end
    end
  end
end
