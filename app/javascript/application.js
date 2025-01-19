// application.js - Ensure this is the single source of Stimulus setup
import { Application } from "@hotwired/stimulus";
const application = Application.start();

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

// Other imports
import "@hotwired/turbo-rails";
import "bootstrap";
import "@popperjs/core";
import "controllers";
