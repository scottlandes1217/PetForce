import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["day", "newEventButton"]

  connect() {
    console.log("Calendar controller connected")
    
    // Listen for sidebar ready event
    this.element.addEventListener('sidebar:ready', () => {
      console.log("Sidebar is ready")
      this.sidebarReady = true
      this.retryCount = 0
      if (this.hasNewEventButtonTarget) {
        this.newEventButtonTarget.removeAttribute('disabled')
      }
    })
    
    // Listen for sidebar content loaded event
    this.element.addEventListener('sidebar:content-loaded', (event) => {
      console.log("Sidebar content loaded:", event.detail.url)
      // Reset retry count when content is successfully loaded
      this.retryCount = 0
    })
  }

  createEvent(event) {
    // Only allow clicking if user has permission and calendars exist
    if (!this.hasCalendars()) {
      this.showNoCalendarsMessage()
      return
    }

    const date = event.currentTarget.dataset.date
    const organizationId = this.getOrganizationId()
    const calendarId = this.getFirstCalendarId()
    
    if (calendarId) {
      const url = `/organizations/${organizationId}/calendars/${calendarId}/events/new?start_time=${date}T09:00:00`
      this.openEventModal({ preventDefault: () => {}, currentTarget: { href: url } })
    }
  }

  hasCalendars() {
    // Check if there are any calendar checkboxes available
    const calendarCheckboxes = document.querySelectorAll('input[name="calendar_ids[]"]')
    return calendarCheckboxes.length > 0
  }

  getFirstCalendarId() {
    const calendarCheckboxes = document.querySelectorAll('input[name="calendar_ids[]"]:checked')
    if (calendarCheckboxes.length > 0) {
      return calendarCheckboxes[0].value
    }
    
    // If no calendars are selected, prioritize organization calendar, then personal, then first available
    const allCalendarCheckboxes = document.querySelectorAll('input[name="calendar_ids[]"]')
    if (allCalendarCheckboxes.length > 0) {
      // Look for organization calendar first
      for (let checkbox of allCalendarCheckboxes) {
        const label = checkbox.nextElementSibling
        if (label.textContent.includes('Org')) {
          return checkbox.value
        }
      }
      
      // Then look for personal calendar
      for (let checkbox of allCalendarCheckboxes) {
        const label = checkbox.nextElementSibling
        if (label.textContent.includes('Personal')) {
          return checkbox.value
        }
      }
      
      // Fallback to first available
      return allCalendarCheckboxes[0].value
    }
    return null
  }

  getOrganizationId() {
    // Extract organization ID from the current URL
    const urlParts = window.location.pathname.split('/')
    return urlParts[2] // /organizations/{id}/events
  }

  showNoCalendarsMessage() {
    // Show a toast or alert message
    const message = "No calendars available. Please create a calendar first."
    
    // Create a simple toast notification
    const toast = document.createElement('div')
    toast.className = 'alert alert-warning alert-dismissible fade show position-fixed'
    toast.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;'
    toast.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `
    
    document.body.appendChild(toast)
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast)
      }
    }, 5000)
  }

  // Handle calendar checkbox changes
  toggleCalendar(event) {
    const checkbox = event.target
    const label = checkbox.nextElementSibling
    
    if (checkbox.checked) {
      label.style.fontWeight = '600'
    } else {
      label.style.fontWeight = '400'
    }
  }

  // Open event in sidebar modal
  openEventModal(event) {
    if (event.currentTarget.disabled) {
      event.preventDefault();
      return;
    }
    event.preventDefault();
    const url = event.currentTarget.dataset?.url || event.currentTarget.href;
    console.log("Opening event modal for URL:", url);
    
    // Find the sidebar controller
    const sidebarElement = document.querySelector('[data-controller*="sidebar"]')
    console.log("Sidebar element found:", !!sidebarElement)
    
    if (sidebarElement) {
      const sidebarController = this.application.getControllerForElementAndIdentifier(sidebarElement, 'sidebar')
      console.log("Sidebar controller found:", !!sidebarController, "Sidebar ready:", this.sidebarReady)
      
      if (sidebarController && this.sidebarReady) {
        // Add turbo_stream format to the URL
        const separator = url.includes('?') ? '&' : '?'
        const sidebarUrl = `${url}${separator}format=turbo_stream`
        console.log("Loading content in sidebar:", sidebarUrl)
        console.log("Event details:", { url, sidebarUrl, sidebarController: !!sidebarController, sidebarReady: this.sidebarReady })
        console.log("About to load content in sidebar...")
        sidebarController.loadContent(sidebarUrl)
      } else {
        // If sidebar controller isn't ready, wait a bit and try again (max 10 attempts)
        if (!this.retryCount) this.retryCount = 0
        if (this.retryCount < 10) {
          this.retryCount++
          console.log(`Retrying... attempt ${this.retryCount}/10`)
          setTimeout(() => {
            this.openEventModal(event)
          }, 200)
        } else {
          // Fallback to regular navigation after max retries
          console.log("Max retries reached, falling back to regular navigation")
          this.retryCount = 0
          this.fallbackToRegularNavigation(url)
        }
      }
    } else {
      // If sidebar element isn't found, fallback to regular navigation
      console.log("Sidebar element not found, falling back to regular navigation")
      this.fallbackToRegularNavigation(url)
    }
  }
  
  // Fallback method for when sidebar is not available
  fallbackToRegularNavigation(url) {
    console.log("Falling back to regular navigation:", url)
    window.location.href = url
  }
  
  // Check if sidebar is available and ready
  isSidebarReady() {
    const sidebarElement = document.querySelector('[data-controller*="sidebar"]')
    if (!sidebarElement) return false
    
    const sidebarController = this.application.getControllerForElementAndIdentifier(sidebarElement, 'sidebar')
    return sidebarController && this.sidebarReady
  }
  
  // Update view when calendar selection changes
  updateView(event) {
    const form = event.target.closest('form')
    if (form) {
      form.requestSubmit()
    }
  }
} 