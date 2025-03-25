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

ActiveRecord::Schema[7.1].define(version: 2025_01_26_014104) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["organization_id"], name: "index_pets_on_organization_id"
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

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.bigint "organization_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "organization_fields", "organizations"
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organization_users", "users"
  add_foreign_key "pets", "organizations"
  add_foreign_key "post_attachments", "posts"
  add_foreign_key "posts", "organizations"
  add_foreign_key "posts", "pets"
  add_foreign_key "posts", "users"
  add_foreign_key "reactions", "posts"
  add_foreign_key "reactions", "users"
  add_foreign_key "tasks", "pets"
  add_foreign_key "users", "organizations"
end
