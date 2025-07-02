import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Pets index controller connected")
  }
  
  async togglePin(event) {
    const button = event.currentTarget
    const petId = button.dataset.petId
    const isPinned = button.classList.contains('pinned')
    
    try {
      if (isPinned) {
        // Unpin the pet
        const response = await fetch(`/pinned_tabs/unpin_pet?pet_id=${petId}`, {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
            'X-Requested-With': 'XMLHttpRequest'
          }
        })
        
        if (response.ok) {
          button.classList.remove('pinned')
          button.title = 'Pin to navigation'
          button.querySelector('i').classList.remove('text-warning')
          
          // Emit unpinned event
          const event = new CustomEvent('pet:unpinned', {
            detail: { petId: petId }
          })
          document.dispatchEvent(event)
        }
      } else {
        // Pin the pet
        const response = await fetch('/pinned_tabs', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
            'X-Requested-With': 'XMLHttpRequest'
          },
          body: JSON.stringify({ pet_id: petId })
        })
        
        if (response.ok) {
          button.classList.add('pinned')
          button.title = 'Unpin from navigation'
          button.querySelector('i').classList.add('text-warning')
          
          // Emit pinned event
          const event = new CustomEvent('pet:pinned', {
            detail: { petId: petId }
          })
          document.dispatchEvent(event)
        }
      }
    } catch (error) {
      console.error('Error toggling pin:', error)
    }
  }
} 