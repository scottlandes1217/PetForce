import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["imageModal", "uploadInput", "selectedImages", "gallery"];

  connect() {
    console.log("Pet controller connected");
    const activeTab = this.getActiveTabFromHash() || "details";
    this.showTab(activeTab);
    this.selectedGalleryImage = null;
    this.uploadedImageFile = null;
  
    // Monitor hash changes for dynamic tab updates
    window.addEventListener("hashchange", () => {
      const newTab = this.getActiveTabFromHash();
      this.showTab(newTab);
    });
  } 

  // Tab Switching Methods
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

  getActiveTabFromHash() {
    return window.location.hash.replace("#", "");
  }

  // Open the modal
  openImageModal() {
    if (this.imageModalTarget) {
      this.imageModalTarget.style.display = "block";
      console.log("Image modal opened");
    }
  }

  // Close the modal
  closeImageModal() {
    if (this.imageModalTarget) {
      this.imageModalTarget.style.display = "none";
      console.log("Image modal closed");
    }
  }

  // Select an image from the gallery
  selectImageFromGallery(event) {
    const photoId = event.currentTarget.dataset.photoId;

    if (!photoId) {
      console.error("No photo ID found for selected image.");
      return;
    }

    // Clear previously selected gallery image
    if (this.selectedGalleryImage) {
      const previousItem = this.galleryTarget.querySelector(
        `.gallery-item[data-photo-id="${this.selectedGalleryImage}"]`
      );
      if (previousItem) {
        previousItem.classList.remove("selected");
      }
    }

    // Set new selected image and mark it
    this.selectedGalleryImage = photoId;
    event.currentTarget.classList.add("selected");
    console.log("Selected gallery image:", photoId);

    // Clear uploaded image since a gallery image is selected
    this.uploadedImageFile = null;

    // Clear the preview section and add the selected gallery image
    this.clearPreview();
    this.addImageToPreview(event.currentTarget.dataset.photoUrl, "Selected Gallery Image");
  }

  // Handle file upload
  uploadInputChanged(event) {
    const files = event.target.files;
  
    if (!files.length) {
      console.error("No files selected.");
      return;
    }
  
    const formData = new FormData();
    Array.from(files).forEach((file) => {
      formData.append("pet[gallery_photos][]", file); // Append each file
    });
  
    // Correctly construct the gallery endpoint URL
    const formAction = `${this.element.dataset.url}/gallery`; // Appends /gallery to the base dataset URL
  
    console.log("Uploading photos to:", formAction);
  
    fetch(formAction, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
    })
      .then((response) => {
        if (response.ok) {
          return response.json();
        } else {
          throw new Error("Failed to upload photos.");
        }
      })
      .then((data) => {
        console.log("Photos uploaded successfully");
  
        // Dynamically update the gallery with new photos
        const galleryContainer = document.querySelector(".gallery-container");
        data.uploaded_photos.forEach((photoUrl) => {
          const newGalleryItem = document.createElement("div");
          newGalleryItem.className = "gallery-item";
  
          const img = document.createElement("img");
          img.src = photoUrl;
          img.className = "gallery-photo";
  
          newGalleryItem.appendChild(img);
          galleryContainer.appendChild(newGalleryItem);
        });
  
        // Clear the file input after upload
        event.target.value = "";
  
        // Ensure the hash stays on the gallery tab
        this.updateHash("gallery");
        this.showTab("gallery");
      })
      .catch((error) => {
        console.error("Error uploading photos:", error);
      });
  }    

  // Add the selected or uploaded image to the preview section
  addImageToPreview(imageSrc, altText) {
    if (!this.selectedImagesTarget) {
      console.error('Missing target element "selectedImages" for "pet" controller');
      return;
    }

    this.selectedImagesTarget.innerHTML = ""; // Clear any existing preview

    const img = document.createElement("img");
    img.src = imageSrc;
    img.alt = altText;
    img.classList.add("thumbnail");

    this.selectedImagesTarget.appendChild(img);
  }

  // Clear the preview section
  clearPreview() {
    if (this.selectedImagesTarget) {
      this.selectedImagesTarget.innerHTML = "";
    }
  }

  // Add the selected image (gallery or uploaded) to the form and close the modal
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
  
    fetch(this.element.dataset.url, {
      method: "PATCH",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
    })
      .then((response) => {
        if (response.ok) {
          return response.json();
        } else {
          throw new Error("Failed to update photo.");
        }
      })
      .then((data) => {
        if (data.photo_url) {
          console.log(data.success_message);
  
          // Update the header image
          const headerPhoto = document.querySelector(".pet-photo");
          if (headerPhoto) {
            headerPhoto.src = data.photo_url;
          }
  
          // Add the uploaded photo to the gallery if it was uploaded
          if (this.uploadedImageFile) {
            const galleryContainer = document.querySelector(".gallery-container");
            if (galleryContainer) {
              const newGalleryItem = document.createElement("div");
              newGalleryItem.className = "gallery-item";
  
              const img = document.createElement("img");
              img.src = data.photo_url;
              img.className = "gallery-photo";
  
              newGalleryItem.appendChild(img);
              galleryContainer.appendChild(newGalleryItem);
            }
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
  
  uploadPhotos(event) {
    event.preventDefault();
  
    const form = event.target.closest("form");
    const formData = new FormData(form);
    const formAction = form.getAttribute("action");
  
    fetch(formAction, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
    })
      .then((response) => {
        if (response.ok) {
          return response.json();
        } else {
          throw new Error("Failed to upload photos.");
        }
      })
      .then((data) => {
        console.log("Photos uploaded successfully");
  
        // Dynamically update the gallery with new photos
        const galleryContainer = document.querySelector(".gallery-container");
        data.uploaded_photos.forEach((photoUrl) => {
          const newGalleryItem = document.createElement("div");
          newGalleryItem.className = "gallery-item";
  
          const img = document.createElement("img");
          img.src = photoUrl;
          img.className = "gallery-photo";
  
          newGalleryItem.appendChild(img);
          galleryContainer.appendChild(newGalleryItem);
        });
  
        // Clear the file input after upload
        form.reset();
  
        // Ensure the hash stays on the gallery tab
        this.updateHash("gallery");
        this.showTab("gallery");
      })
      .catch((error) => {
        console.error("Error uploading photos:", error);
      });
  }   

  // Add the uploaded image to the gallery automatically
  addToGallery(file) {
    const img = document.createElement("img");
    img.src = URL.createObjectURL(file);
    img.alt = "New Gallery Image";
    img.classList.add("gallery-photo");

    const galleryContainer = document.querySelector(".gallery-container");
    const imgWrapper = document.createElement("div");
    imgWrapper.classList.add("gallery-item");
    imgWrapper.appendChild(img);

    galleryContainer.appendChild(imgWrapper);
    console.log("Uploaded image added to the gallery.");
  }

  deletePhoto(event) {
    event.preventDefault();
  
    const deleteButton = event.currentTarget;
    const form = deleteButton.closest("form"); // Get the enclosing form
    const formAction = form.getAttribute("action"); // Extract the form action URL
  
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
        if (response.ok) {
          console.log("Photo deleted successfully");
          form.closest(".gallery-item").remove(); // Remove the gallery item
        } else {
          console.error("Failed to delete the gallery photo.");
        }
      })
      .catch((error) => {
        console.error("Error deleting photo:", error);
      });
  }    
}