import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Turbo Stream controller connected")
    
    // Log when Turbo Stream events occur
    document.addEventListener("turbo:before-stream-render", (event) => {
      console.log("Turbo Stream before render:", event)
    })

    document.addEventListener("turbo:before-cache", (event) => {
      console.log("Turbo Stream before cache:", event)
    })

    document.addEventListener("turbo:render", (event) => {
      console.log("Turbo Stream render:", event)
    })
  }
} 