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

import TurboStreamController from "./controllers/turbo_stream_controller";
application.register("turbo-stream", TurboStreamController);

// Other imports
import "bootstrap";
import "@popperjs/core";
import "controllers";

// Import channels
import "./channels"
