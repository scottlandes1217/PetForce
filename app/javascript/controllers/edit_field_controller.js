import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value", "input", "editButton", "saveButton", "cancelButton", "photoInput", "photo"];

  connect() {
    console.log("Connecting EditFieldController...");

    if (this.initialized) {
      console.warn("Controller already initialized, skipping...");
      return;
    }
    this.initialized = true;

    this.url = this.element.dataset.url;
    console.log("EditFieldController connected for element:", this.element);

    this.currentValues = new Map();
    this.changedFields = new Set();
    this.isSaving = false;

    this.inputTargets.forEach((input) => {
      this.currentValues.set(input.dataset.field, input.value);
    });
  }

  edit(event) {
    event.preventDefault();
    event.stopPropagation();

    const field = event.target.dataset.field;
    const valueElement = this.valueTargets.find((el) => el.dataset.field === field);
    const inputElement = this.inputTargets.find((el) => el.dataset.field === field);

    valueElement.style.display = "none";
    inputElement.style.display = "inline-block";
    inputElement.focus();
    event.target.style.display = "none";

    this.showCancelButton();

    inputElement.addEventListener("input", () => {
      if (inputElement.value !== this.currentValues.get(field)) {
        this.changedFields.add(field);
        this.showSaveButton();
      } else {
        this.changedFields.delete(field);
        this.hideSaveButton();
      }
    });
  }

  cancel(event) {
    event.preventDefault();
    event.stopPropagation();
  
    console.log("Cancel button clicked. Reverting changes...");
  
    // Revert changes to the input fields
    this.inputTargets.forEach((input) => {
      const field = input.dataset.field;
      const originalValue = this.currentValues.get(field);
  
      if (input.tagName === "SELECT" && input.multiple) {
        // Multi-select fields: reset selected options
        Array.from(input.options).forEach((option) => {
          option.selected = originalValue.includes(option.value);
        });
      } else {
        // Single value fields
        input.value = originalValue;
      }
    });
  
    // Update the UI to reflect the reverted changes
    this.updateUI();
  
    // Clear any pending changes and hide buttons
    this.changedFields.clear();
    this.hideSaveButton();
    this.hideCancelButton();
  }  

  save(event) {
    if (event) event.preventDefault();
  
    if (this.isSaving) {
      console.warn("Save is already in progress. Ignoring duplicate request.");
      return;
    }
  
    this.isSaving = true;
  
    const data = {};
    this.inputTargets.forEach((input) => {
      if (this.changedFields.has(input.dataset.field)) {
        data[input.dataset.field] = input.value;
      }
    });
  
    console.log("Sending data:", data);
  
    fetch(this.url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify({ pet: data }),
    })
      .then((response) => {
        console.log("Fetch response received. Status:", response.status);
        if (!response.ok) {
          throw new Error(`Network response was not ok. Status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        console.log("Pet updated successfully:", data);
        this.showSuccessMessage(data.success_message || "Pet details updated successfully!");
  
        // Update currentValues for all saved fields
        this.inputTargets.forEach((input) => {
          const field = input.dataset.field;
          if (this.changedFields.has(field)) {
            this.currentValues.set(field, input.value);
          }
        });
  
        // Reset the UI
        this.updateUI();
      })
      .catch((error) => {
        console.error("Error updating pet:", error);
        this.showErrorMessage("Failed to update pet. Please try again.");
      })
      .finally(() => {
        this.isSaving = false;
      });
  }  

  triggerPhotoUpload() {
    console.log("Photo upload triggered");
    if (this.photoInputTarget) {
      this.photoInputTarget.click(); // Programmatically click the file input
    } else {
      console.error("Photo input target not found");
    }
  }  

  uploadPhoto(event) {
    const file = event.target.files[0];
    if (!file) return;

    const formData = new FormData();
    formData.append("pet[photo]", file);

    fetch(this.url, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
      body: formData,
    })
      .then((response) => {
        console.log("Photo upload response received. Status:", response.status);
        if (!response.ok) {
          throw new Error("Photo upload failed");
        }
        return response.json();
      })
      .then((data) => {
        console.log("Photo uploaded successfully:", data);

        if (this.photoTarget) {
          this.photoTarget.src = data.photo_url;
        }

        this.showSuccessMessage("Photo updated successfully!");
      })
      .catch((error) => {
        console.error("Error uploading photo:", error);
        this.showErrorMessage("Failed to upload photo. Please try again.");
      });
  }

  updateUI() {
    this.inputTargets.forEach((input) => {
      const field = input.dataset.field;
      const valueElement = this.valueTargets.find((el) => el.dataset.field === field);
      const editButton = this.editButtonTargets.find((el) => el.dataset.field === field);
  
      let formattedValue;
  
      if (input.tagName === "SELECT" && input.multiple) {
        // Handle multi-select fields
        const selectedValues = Array.from(input.selectedOptions).map((option) => option.textContent);
        formattedValue = selectedValues.join(", ") || "None";
      } else if (input.tagName === "SELECT") {
        // Handle single-select dropdowns
        const selectedOption = input.selectedOptions[0];
        formattedValue = selectedOption ? selectedOption.textContent : "None";
      } else if (input.type === "text" || input.tagName === "TEXTAREA") {
        // Freeform text fields: use raw input value
        formattedValue = input.value;
      } else {
        // Apply humanization for other field types
        formattedValue = this.humanizeValue(input.value);
      }
  
      valueElement.textContent = formattedValue;
  
      // Reset the visibility of the field
      valueElement.style.display = "inline-block";
      input.style.display = "none";
      if (editButton) {
        editButton.style.display = "inline-block";
      }
    });
  
    // Clear changed fields and hide buttons
    this.changedFields.clear();
    this.hideSaveButton();
    this.hideCancelButton();
  }  
  
  // Helper to humanize values
  humanizeValue(value) {
    if (Array.isArray(value)) {
      return value.map(this.humanizeString).join(", ");
    }
    if (typeof value === "string") {
      return this.humanizeString(value);
    }
    return value; // Return as is for other types (e.g., numbers, dates)
  }
  
  humanizeString(str) {
    return str
      .replace(/_/g, " ") // Replace underscores with spaces
      .replace(/\b\w/g, (char) => char.toUpperCase()); // Capitalize each word
  }   

  showSaveButton() {
    if (this.saveButtonTarget) {
      this.saveButtonTarget.style.display = "inline-block";
    }
  }

  hideSaveButton() {
    if (this.saveButtonTarget) {
      this.saveButtonTarget.style.display = "none";
    }
  }

  showCancelButton() {
    if (this.cancelButtonTarget) {
      // Show the cancel button
      this.cancelButtonTarget.style.display = "inline-block";
  
      // Show the parent button-container
      const buttonContainer = this.cancelButtonTarget.closest(".button-container");
      if (buttonContainer) {
        buttonContainer.style.display = "inline-block";
      }
    }
  }
  
  hideCancelButton() {
    if (this.cancelButtonTarget) {
      // Hide the cancel button
      this.cancelButtonTarget.style.display = "none";
  
      // Hide the parent button-container if no buttons are visible
      const buttonContainer = this.cancelButtonTarget.closest(".button-container");
      if (buttonContainer) {
        const buttons = buttonContainer.querySelectorAll("button");
        const anyButtonVisible = Array.from(buttons).some((button) => button.style.display !== "none");
        if (!anyButtonVisible) {
          buttonContainer.style.display = "none";
        }
      }
    }
  }
  

  showSuccessMessage(message) {
    const successMessage = document.createElement("div");
    successMessage.className = "alert alert-success";
    successMessage.textContent = message;
    document.body.appendChild(successMessage);
    setTimeout(() => successMessage.remove(), 3000);
  }

  showErrorMessage(message) {
    const errorMessage = document.createElement("div");
    errorMessage.className = "alert alert-danger";
    errorMessage.textContent = message;
    document.body.appendChild(errorMessage);
    setTimeout(() => errorMessage.remove(), 3000);
  }
}