// application.js - Ensure this is the single source of Stimulus setup
import { Application } from "@hotwired/stimulus";
const application = Application.start();

// Import Turbo
import "@hotwired/turbo-rails";
import { Turbo } from "@hotwired/turbo-rails";

// Import controllers
import EditFieldController from "./controllers/edit_field_controller";
application.register("edit-field", EditFieldController);

import FeedController from "./controllers/feed_controller";
application.register("feed", FeedController);

import ReactionController from "./controllers/reaction_controller";
application.register("reaction", ReactionController);

import PostController from "./controllers/post_controller";
application.register("post", PostController);

import PetController from "./controllers/pet_controller";
application.register("pet", PetController);

import OrganizationFieldsController from "./controllers/organization_fields_controller";
application.register("organization-fields", OrganizationFieldsController);

import TaskUpdatesController from "./controllers/task_updates_controller";
application.register("task-updates", TaskUpdatesController);

import CalendarController from "./controllers/calendar_controller";
application.register("calendar", CalendarController);

import SidebarController from "./controllers/sidebar_controller";
application.register("sidebar", SidebarController);

import EventFormController from "./controllers/event_form_controller";
application.register("event-form", EventFormController);

import CalendarSharingController from "./controllers/calendar_sharing_controller";
application.register("calendar-sharing", CalendarSharingController);

import TurboStreamController from "./controllers/turbo_stream_controller";
application.register("turbo-stream", TurboStreamController);

// Other imports
import "bootstrap";
import "@popperjs/core";

// Import channels
import "./channels"

import "trix"
import "@rails/actiontext"

import Rails from "@rails/ujs";
Rails.start();

console.log("moveGlobalAlertToBody loaded");

document.addEventListener("turbo:load", () => {
  console.log("turbo:load event fired");
  moveGlobalAlertToBody();
});
document.addEventListener("turbo:frame-load", () => {
  console.log("turbo:frame-load event fired");
  moveGlobalAlertToBody();
});

function moveGlobalAlertToBody() {
  console.log("moveGlobalAlertToBody called");
  document.querySelectorAll('.global-top-alert').forEach(alert => {
    if (alert.parentNode !== document.body) {
      document.body.appendChild(alert);
    }
  });
}

// MutationObserver to move global-top-alerts whenever they appear
const observer = new MutationObserver(() => {
  moveGlobalAlertToBody();
});
observer.observe(document.body, { childList: true, subtree: true });
