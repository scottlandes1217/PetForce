module SitesHelper
  def site_builder_field_metadata_json
    pet_fields = [
      { name: 'name', type: 'text', label: 'Pet Name' },
      { name: 'age', type: 'number', label: 'Age' },
      { name: 'species', type: 'picklist', label: 'Species', options: OrganizationField.where(organization: @organization, field_type: :species).pluck(:value) },
      { name: 'adopted', type: 'checkbox', label: 'Adopted' },
      { name: 'description', type: 'textarea', label: 'Description' }
    ]
    task_fields = [
      { name: 'subject', type: 'text', label: 'Task Subject' },
      { name: 'due_date', type: 'date', label: 'Due Date' },
      { name: 'priority', type: 'picklist', label: 'Priority', options: Task::STATUSES }
    ]
    {
      pet_fields: pet_fields,
      task_fields: task_fields
    }.to_json.html_safe
  end
end 