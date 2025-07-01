import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["alert"]

  connect() {
    // Move the alert to the body so it's global
    this.moveAlertToBody();

    // Observe for re-renders (Turbo, etc.)
    this.observer = new MutationObserver(() => {
      this.moveAlertToBody();
    });
    this.observer.observe(this.element, { childList: true, subtree: true });
  }

  disconnect() {
    if (this.observer) this.observer.disconnect();
  }

  moveAlertToBody() {
    if (this.hasAlertTarget && this.alertTarget.parentNode !== document.body) {
      document.body.appendChild(this.alertTarget);
    }
  }

  close(event) {
    this.alertTarget.remove();
  }
} 