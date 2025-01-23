import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("OrganizationFieldsController connected!");
  }

  // Add new field
  addField(event) {
    event.preventDefault();
  
    const form = event.target.closest("form");
    const formData = new FormData(form); // Collect all form data
  
    // Get the CSRF token from the meta tag
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");
  
    fetch(form.action, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken, // Include CSRF token
      },
      body: formData, // Send the entire form data
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        console.log(data); // Log the new field data
        if (data.id) {
          const list = document.getElementById(`${form.dataset.fieldType}-list`);
          const newItem = document.createElement("li");
          newItem.className = "list-group-item d-flex justify-content-between align-items-center";
          newItem.dataset.fieldId = data.id;
          newItem.innerHTML = `
            ${data.value} 
            ${data.icon_url ? `<img src="${data.icon_url}" alt="${data.value} Icon" style="width: 24px; height: 24px; margin-left: 10px;">` : ""}
            ${data.priority ? ` (<span>Priority: ${data.priority}</span>)` : ""}
            <button class="delete-field btn btn-sm btn-danger" data-action="organization-fields#deleteField" data-field-id="${data.id}">Delete</button>
          `;
          list.appendChild(newItem);
          form.reset(); // Clear the form inputs
        } else {
          alert("Failed to save the field. Please try again.");
        }
      })
      .catch((error) => {
        console.error("Error adding field:", error);
        alert("An error occurred. Please try again.");
      });
  }

  // Delete field
  deleteField(event) {
    const button = event.target;
    if (button.classList.contains("delete-field")) {
      const fieldId = button.dataset.fieldId;
      const organizationId = button.closest(".add-field-form").dataset.organizationId;

      fetch(`/organizations/${organizationId}/organization_fields`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ organization_field: { field_type: fieldType, value: value } }),
      }).then((response) => {
        if (response.ok) {
          button.parentElement.remove();
        } else {
          alert("Failed to delete the field.");
        }
      });
    }
  }
}