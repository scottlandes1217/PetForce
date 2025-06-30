import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Turbo Stream controller connected")
    console.log("Controller element:", this.element)
    
    // Log when Turbo Stream events occur
    document.addEventListener("turbo:before-stream-render", (event) => {
      console.log("Turbo Stream before render:", event)
      console.log("Target:", event.target)
      console.log("Action:", event.action)
      console.log("Template:", event.template)
      console.log("Event detail:", event.detail)
    })

    document.addEventListener("turbo:before-cache", (event) => {
      console.log("Turbo Stream before cache:", event)
      console.log("Event detail:", event.detail)
    })

    document.addEventListener("turbo:render", (event) => {
      console.log("Turbo Stream render:", event)
      console.log("Target:", event.target)
      console.log("Action:", event.action)
      console.log("Template:", event.template)
      console.log("Event detail:", event.detail)
    })

    // Log when Turbo Streams are received
    document.addEventListener("turbo:stream-receive", (event) => {
      console.log("Turbo Stream received:", event)
      console.log("Target:", event.target)
      console.log("Action:", event.action)
      console.log("Template:", event.template)
      console.log("Event detail:", event.detail)
    })

    // Log when Turbo Streams are processed
    document.addEventListener("turbo:before-stream-process", (event) => {
      console.log("Turbo Stream before process:", event)
      console.log("Event detail:", event.detail)
    })

    document.addEventListener("turbo:stream-process", (event) => {
      console.log("Turbo Stream process:", event)
      console.log("Event detail:", event.detail)
    })

    // Log any errors
    document.addEventListener("turbo:error", (event) => {
      console.error("Turbo Stream error:", event)
      console.error("Event detail:", event.detail)
    })
  }
} 