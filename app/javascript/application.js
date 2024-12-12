// application.js - Ensure this is the single source of Stimulus setup
import { Application } from "@hotwired/stimulus";
const application = Application.start();

import EditFieldController from "./controllers/edit_field_controller";
application.register("edit-field", EditFieldController);

import FeedController from "./controllers/feed_controller";
application.register("feed", FeedController);

import PostController from "./controllers/post_controller";
application.register("post", PostController);

import PetController from "./controllers/pet_controller";
application.register("pet", PetController);

// Other imports
import "@hotwired/turbo-rails";
import "bootstrap";
import "@popperjs/core";
import "controllers";
