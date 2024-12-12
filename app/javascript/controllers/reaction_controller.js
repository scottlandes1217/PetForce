import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { postId: Number };

  react(event) {
    const reactionType = event.target.dataset.reactionType;

    fetch(`/posts/${this.postIdValue}/reactions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify({ reaction_type: reactionType }),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Failed to add reaction.");
        }
        return response.json();
      })
      .then((data) => {
        alert(data.message);
        // Optionally reload or update the DOM to reflect the new reaction
      })
      .catch((error) => {
        console.error(error);
        alert("Something went wrong!");
      });
  }
}