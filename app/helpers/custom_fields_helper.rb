module CustomFieldsHelper
  def built_in_field?(custom_field)
    # Built-in fields are those that correspond to core pet/task/event attributes
    built_in_api_names = [
      'pet_species_field',
      'pet_breed_field', 
      'pet_color_field',
      'pet_flags_field',
      'pet_location_field',
      'pet_unit_field',
      'task_unit_field',
      'task_location_field'
    ]
    
    built_in_api_names.include?(custom_field.api_name)
  end
end 