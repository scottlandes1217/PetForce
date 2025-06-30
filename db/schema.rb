# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_06_30_090000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ad_impressions", force: :cascade do |t|
    t.bigint "ad_id", null: false
    t.bigint "user_id"
    t.string "impression_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ad_id"], name: "index_ad_impressions_on_ad_id"
    t.index ["user_id"], name: "index_ad_impressions_on_user_id"
  end

  create_table "ads", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "global_frequency"
    t.integer "max_impressions_per_user"
    t.integer "user_cooldown_seconds"
    t.text "include_locations"
    t.text "exclude_locations"
    t.decimal "revenue_generated", default: "0.0"
    t.decimal "revenue_share_percentage", default: "0.0"
    t.integer "impressions_count", default: 0
    t.integer "clicks_count", default: 0
    t.text "pet_types"
    t.string "status"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.text "target_states"
    t.text "target_counties"
    t.text "target_cities"
    t.text "target_zip_codes"
    t.float "target_latitude"
    t.float "target_longitude"
    t.float "target_radius_miles"
    t.integer "min_age"
    t.integer "max_age"
    t.text "target_genders"
    t.text "target_pet_breeds"
    t.integer "min_pet_age"
    t.integer "max_pet_age"
    t.integer "impression_cap"
    t.integer "click_cap"
    t.integer "budget_cents"
    t.integer "parent_ad_id"
  end

  create_table "comment_reactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "comment_id", null: false
    t.string "reaction_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_reactions_on_comment_id"
    t.index ["user_id", "comment_id"], name: "index_comment_reactions_on_user_id_and_comment_id", unique: true
    t.index ["user_id"], name: "index_comment_reactions_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "organization_fields", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.integer "field_type"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
    t.integer "priority"
    t.index ["organization_id"], name: "index_organization_fields_on_organization_id"
  end

  create_table "organization_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_organization_users_on_organization_id"
    t.index ["user_id"], name: "index_organization_users_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations_users", id: false, force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id", "user_id"], name: "index_organizations_users_on_organization_id_and_user_id"
    t.index ["user_id", "organization_id"], name: "index_organizations_users_on_user_id_and_organization_id"
  end

  create_table "pets", force: :cascade do |t|
    t.string "name"
    t.json "breed"
    t.integer "age"
    t.text "description"
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sex", default: 2, null: false
    t.integer "species_id"
    t.json "color"
    t.integer "coat_type"
    t.integer "size"
    t.float "weight_lbs"
    t.float "weight_oz"
    t.date "entered_shelter"
    t.date "left_shelter"
    t.integer "unit_id"
    t.integer "location_id"
    t.date "date_of_birth"
    t.boolean "dob_estimated", default: false
    t.string "microchip"
    t.date "dod"
    t.integer "mother_id"
    t.integer "father_id"
    t.json "flags"
    t.bigint "owner_id"
    t.index ["organization_id"], name: "index_pets_on_organization_id"
    t.index ["owner_id"], name: "index_pets_on_owner_id"
  end

  create_table "post_attachments", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_post_attachments_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "user_id"
    t.bigint "organization_id"
    t.bigint "pet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_posts_on_organization_id"
    t.index ["pet_id"], name: "index_posts_on_pet_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.string "reaction_type", null: false
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_reactions_on_post_id"
    t.index ["user_id", "post_id", "reaction_type"], name: "index_reactions_on_user_id_and_post_id_and_reaction_type", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "status", default: "Scheduled", null: false
    t.string "subject", null: false
    t.text "description"
    t.bigint "pet_id", null: false
    t.datetime "completed_at"
    t.datetime "start_time"
    t.integer "duration_minutes"
    t.string "task_type"
    t.string "flag_list", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_tasks_on_pet_id"
  end

  create_table "user_ad_rewards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "ad_id", null: false
    t.decimal "amount", default: "0.0"
    t.boolean "donated", default: false
    t.string "donated_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ad_id"], name: "index_user_ad_rewards_on_ad_id"
    t.index ["user_id"], name: "index_user_ad_rewards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.bigint "organization_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "impersonated_by_id"
    t.integer "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "state"
    t.string "county"
    t.string "city"
    t.string "zip_code"
    t.float "latitude"
    t.float "longitude"
    t.date "birthdate"
    t.integer "gender"
    t.boolean "can_post_as_organization", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ad_impressions", "ads"
  add_foreign_key "ad_impressions", "users"
  add_foreign_key "comment_reactions", "comments"
  add_foreign_key "comment_reactions", "users"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "organization_fields", "organizations"
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organization_users", "users"
  add_foreign_key "pets", "organizations"
  add_foreign_key "pets", "users", column: "owner_id"
  add_foreign_key "post_attachments", "posts"
  add_foreign_key "posts", "organizations"
  add_foreign_key "posts", "pets"
  add_foreign_key "posts", "users"
  add_foreign_key "reactions", "posts"
  add_foreign_key "reactions", "users"
  add_foreign_key "tasks", "pets"
  add_foreign_key "user_ad_rewards", "ads"
  add_foreign_key "user_ad_rewards", "users"
  add_foreign_key "users", "organizations"
end
