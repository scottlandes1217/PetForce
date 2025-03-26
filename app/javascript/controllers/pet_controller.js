import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["imageModal", "uploadInput", "selectedImages", "gallery"];

  connect() {
    console.log("Pet controller connected");
    const activeTab = this.getActiveTabFromQuery() || this.getActiveTabFromHash() || "details";
    this.showTab(activeTab);
    this.selectedGalleryImage = null;
    this.uploadedImageFile = null;
  
    // Monitor hash changes for dynamic tab updates
    window.addEventListener("hashchange", () => {
      const newTab = this.getActiveTabFromHash();
      this.showTab(newTab);
    });
  }

  /* -----------------------------------------
   * TAB SWITCHING
   * ----------------------------------------- */
  switchTab(event) {
    const tab = event.currentTarget.dataset.tab;
    this.showTab(tab);
    this.updateHash(tab);
  }

  showTab(tab) {
    document.querySelectorAll(".tab-content").forEach((content) => {
      content.style.display = content.id === tab ? "block" : "none";
    });

    document.querySelectorAll(".tab-link").forEach((link) => {
      link.classList.toggle("active", link.dataset.tab === tab);
    });
  }

  updateHash(tab) {
    history.replaceState(null, null, `#${tab}`);
  }

  getActiveTabFromQuery() {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get('tab');
  }

  getActiveTabFromHash() {
    return window.location.hash.replace("#", "");
  }

  /* -----------------------------------------
   * MODAL OPEN/CLOSE
   * ----------------------------------------- */
  openImageModal() {
    if (this.imageModalTarget) {
      this.imageModalTarget.style.display = "block";
      console.log("Image modal opened");
  
      // 1) Unmark any previously selected gallery item
      if (this.selectedGalleryImage) {
        const prevDiv = this.galleryTarget.querySelector(
          `.gallery-item[data-photo-id="${this.selectedGalleryImage}"]`
        );
        if (prevDiv) {
          prevDiv.classList.remove("selected");
        }
        this.selectedGalleryImage = null;
      }
  
      // 2) Clear the preview section
      this.clearPreview();
    }
  }

  closeImageModal() {
    if (this.imageModalTarget) {
      this.imageModalTarget.style.display = "none";
      console.log("Image modal closed");
    }
  }

  /* -----------------------------------------
   * SELECT A GALLERY IMAGE (for main photo)
   * ----------------------------------------- */
  selectImageFromGallery(event) {
    console.log("selectImageFromGallery called!");
    const photoId = event.currentTarget.dataset.photoId;
    const photoUrl = event.currentTarget.dataset.photoUrl;

    if (!photoId) {
      console.error("No photo ID found for selected image.");
      return;
    }

    // Unmark previous selection
    if (this.selectedGalleryImage) {
      const prevDiv = this.galleryTarget.querySelector(
        `.gallery-item[data-photo-id="${this.selectedGalleryImage}"]`
      );
      if (prevDiv) prevDiv.classList.remove("selected");
    }

    // Mark this new selection
    this.selectedGalleryImage = photoId;
    event.currentTarget.classList.add("selected");

    // Clear any uploaded file reference
    this.uploadedImageFile = null;

    // Show a preview
    this.clearPreview();
    this.addImageToPreview(photoUrl, "Selected Gallery Image");
  }

  /* -----------------------------------------
   * UPLOAD PHOTOS -> Re-render partial
   * ----------------------------------------- */
  uploadInputChanged(event) {
    const files = event.target.files;
    if (!files.length) {
      console.error("No files selected.");
      return;
    }
  
    const formData = new FormData();
    Array.from(files).forEach((file) => {
      formData.append("pet[gallery_photos][]", file);
    });
  
    // e.g., "/organizations/1/pets/42/gallery"
    const formAction = `${this.element.dataset.url}/gallery`;
    console.log("Uploading photos to:", formAction);
  
    fetch(formAction, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
    })
      .then((response) => {
        if (!response.ok) throw new Error("Failed to upload photos.");
        return response.json();
      })
      .then((data) => {
        console.log("Photos uploaded successfully");
  
        // 1) Update the main gallery
        const galleryContainer = document.querySelector(".gallery-container");
        if (galleryContainer && data.html) {
          galleryContainer.innerHTML = data.html;
        }
  
        // 2) Update the modal gallery
        if (this.hasGalleryTarget && data.modal_html) {
          this.galleryTarget.innerHTML = data.modal_html;
        }
  
        // 3) Auto-select newly uploaded photos in the modal
        if (this.hasGalleryTarget && data.newly_uploaded_ids?.length > 0) {
          // For simplicity, just auto-select the last uploaded photo
          const latestId = data.newly_uploaded_ids[data.newly_uploaded_ids.length - 1];
  
          const newItem = this.galleryTarget.querySelector(
            `.gallery-item[data-photo-id="${latestId}"]`
          );
          if (newItem) {
            // Unselect previously selected image
            if (this.selectedGalleryImage) {
              const prevDiv = this.galleryTarget.querySelector(
                `.gallery-item[data-photo-id="${this.selectedGalleryImage}"]`
              );
              if (prevDiv) prevDiv.classList.remove("selected");
            }
  
            // Mark and preview the new photo
            this.selectedGalleryImage = latestId;
            newItem.classList.add("selected");
  
            this.clearPreview();
            const photoUrl = newItem.dataset.photoUrl;
            this.addImageToPreview(photoUrl, "Newly Uploaded Photo");
          }
        }
  
        // Clear the file input
        event.target.value = "";
  
        // Optionally switch to the "gallery" tab
        this.updateHash("gallery");
        this.showTab("gallery");
      })
      .catch((error) => {
        console.error("Error uploading photos:", error);
      });
  }

  /* -----------------------------------------
   * SHOW PREVIEW FOR SELECTED IMAGE
   * ----------------------------------------- */
  addImageToPreview(imageSrc, altText) {
    if (!this.selectedImagesTarget) {
      console.error('Missing target element "selectedImages" for "pet" controller');
      return;
    }

    this.selectedImagesTarget.innerHTML = ""; // Clear old preview

    const img = document.createElement("img");
    img.src = imageSrc;
    img.alt = altText;
    img.classList.add("thumbnail");

    this.selectedImagesTarget.appendChild(img);
  }

  clearPreview() {
    if (this.selectedImagesTarget) {
      this.selectedImagesTarget.innerHTML = "";
    }
  }

  /* -----------------------------------------
   * ADD SELECTED IMAGE -> Update Main Photo
   * ----------------------------------------- */
  addSelectedImage(event) {
    event.preventDefault();
    if (!this.selectedGalleryImage && !this.uploadedImageFile) {
      console.error("No image selected or uploaded.");
      return;
    }
  
    const formData = new FormData();
    if (this.selectedGalleryImage) {
      formData.append("gallery_image_id", this.selectedGalleryImage);
    } else if (this.uploadedImageFile) {
      formData.append("pet[photo]", this.uploadedImageFile);
    }
  
    // PATCH to /pets/:id
    fetch(this.element.dataset.url, {
      method: "PATCH",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
    })
      .then((response) => {
        if (!response.ok) throw new Error("Failed to update photo.");
        return response.json();
      })
      .then((data) => {
        if (data.photo_url) {
          console.log(data.success_message || "Photo updated successfully!");
          // Update the main header image
          const headerPhoto = document.querySelector(".pet-photo");
          if (headerPhoto) {
            headerPhoto.src = data.photo_url;
          }
        } else {
          console.error("No photo URL returned from server.");
        }
      })
      .catch((error) => {
        console.error("Error updating photo:", error);
      });
  
    this.closeImageModal();
  }

  /* -----------------------------------------
   * DELETE PHOTO -> Re-render partial
   * ----------------------------------------- */
  deletePhoto(event) {
    event.preventDefault();

    const deleteButton = event.currentTarget;
    const form = deleteButton.closest("form"); 
    const formAction = form.getAttribute("action"); // e.g. /pets/:id/gallery?photo_id=123

    console.log("Form action URL:", formAction);
    if (!formAction) {
      console.error("No form action URL found for the delete button.");
      return;
    }

    fetch(formAction, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json",
      },
    })
      .then((response) => {
        if (!response.ok) throw new Error("Failed to delete the gallery photo.");
        return response.json();
      })
      .then((data) => {
        console.log("Photo deleted successfully");

        // Update main gallery
        const galleryContainer = document.querySelector(".gallery-container");
        if (galleryContainer && data.html) {
          galleryContainer.innerHTML = data.html;
        }

        // Update modal gallery
        if (this.hasGalleryTarget && data.modal_html) {
          this.galleryTarget.innerHTML = data.modal_html;
        }
      })
      .catch((error) => {
        console.error("Error deleting photo:", error);
      });
  }
}