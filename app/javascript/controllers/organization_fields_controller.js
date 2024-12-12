import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("OrganizationFieldsController connected!");
  }

  // Add new field
  addField(event) {
    event.preventDefault();
    const form = event.target.closest("form");
    const fieldType = form.dataset.fieldType;
    const input = form.querySelector("input");
    const value = input.value.trim();
    const organizationId = form.dataset.organizationId;
  
    // Get the CSRF token from the meta tag
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");
  
    if (value) {
      fetch(`/organizations/${organizationId}/organization_fields`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken, // Include CSRF token in headers
        },
        body: JSON.stringify({ organization_field: { field_type: fieldType, value: value } }),
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
            const list = document.getElementById(`${fieldType}-list`);
            const newItem = document.createElement("li");
            newItem.className = "list-group-item d-flex justify-content-between align-items-center";
            newItem.dataset.fieldId = data.id;
            newItem.innerHTML = `
              ${data.value} 
              <button class="delete-field btn btn-sm btn-danger" data-action="organization-fields#deleteField" data-field-id="${data.id}">Delete</button>
            `;
            list.appendChild(newItem);
            input.value = ""; // Clear the input field
          } else {
            alert("Failed to save the field. Please try again.");
          }
        })
        .catch((error) => {
          console.error("Error adding field:", error);
          alert("An error occurred. Please try again.");
        });
    }
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