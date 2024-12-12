import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["posts", "loadingIndicator"];

  connect() {
    console.log("Feed controller connected");

    // Force scroll to the top on page load
    window.scrollTo(0, 0);

    this.loading = false;
    this.nextPage = 2; // Start loading from page 2
    this.noMorePosts = false; // Flag for no more posts
    this.noMorePostsElement = document.getElementById("no-more-posts"); // Cache the "No more posts" element
    window.addEventListener("scroll", this.onScroll.bind(this));
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll.bind(this));
  }

  onScroll() {
    if (this.loading || !this.nextPage || this.noMorePosts) return;

    const nearBottom =
      window.innerHeight + window.scrollY >= document.body.offsetHeight - 200;

    if (nearBottom) {
      this.loadMorePosts();
    }
  }

  async loadMorePosts() {
    this.loading = true;
    this.loadingIndicatorTarget.style.display = "block";
    this.loadingIndicatorTarget.textContent = "Loading...";

    try {
      console.log(`Fetching page: ${this.nextPage}`);
      const response = await fetch(`/feed?page=${this.nextPage}`, {
        headers: {
          Accept: "application/json",
        },
      });

      if (!response.ok) {
        console.error(`Failed to fetch more posts (status: ${response.status})`);
        throw new Error(`Failed to fetch more posts (status: ${response.status})`);
      }

      const data = await response.json();
      console.log("Fetched posts:", data);

      if (data.posts) {
        this.postsTarget.insertAdjacentHTML("beforeend", data.posts);
      }

      if (data.next_page) {
        this.nextPage = data.next_page;
      } else {
        console.log("No more pages to load");
        this.nextPage = null;
        this.noMorePosts = true;
        this.showNoMorePostsMessage();
      }
    } catch (error) {
      console.error("Error loading posts:", error);

      if (error.message.includes("500")) {
        console.log("Server returned 500. Assuming no more posts.");
        this.nextPage = null;
        this.noMorePosts = true;
        this.showNoMorePostsMessage();
      }
    } finally {
      this.loading = false;
      this.loadingIndicatorTarget.style.display = "none";
    }
  }

  showNoMorePostsMessage() {
    if (this.noMorePostsElement) {
      this.noMorePostsElement.style.display = "block"; // Show "No more posts" message
      console.log("Displayed 'No more posts' message");
    } else {
      console.warn("No more posts element not found. Cannot display 'No more posts' message.");
    }
  }
}