# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141031223050) do

  create_table "identities", force: true do |t|
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true

  create_table "project_members", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "project_id",             null: false
    t.integer  "role",       default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_members", ["project_id"], name: "index_project_members_on_project_id"
  add_index "project_members", ["user_id", "project_id"], name: "index_project_members_on_user_id_and_project_id", unique: true
  add_index "project_members", ["user_id"], name: "index_project_members_on_user_id"

  create_table "project_openings", force: true do |t|
    t.integer  "project_id", null: false
    t.integer  "user_id",    null: false
    t.integer  "touched"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_openings", ["project_id"], name: "index_project_openings_on_project_id"
  add_index "project_openings", ["user_id", "project_id"], name: "index_project_openings_on_user_id_and_project_id", unique: true
  add_index "project_openings", ["user_id"], name: "index_project_openings_on_user_id"

  create_table "project_snapshots", force: true do |t|
    t.integer  "project_id",         null: false
    t.integer  "task_count"
    t.integer  "original_estimate"
    t.integer  "work_logged"
    t.integer  "remaining_estimate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_snapshots", ["project_id"], name: "index_project_snapshots_on_project_id"

  create_table "projects", force: true do |t|
    t.string   "code",                    default: "", null: false
    t.string   "name",                    default: "", null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string   "state"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "tasks", force: true do |t|
    t.string   "name",               default: "", null: false
    t.text     "description"
    t.integer  "original_estimate"
    t.integer  "remaining_estimate"
    t.integer  "project_id",                      null: false
    t.integer  "assignee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iid"
  end

  add_index "tasks", ["assignee_id"], name: "index_tasks_on_assignee_id"
  add_index "tasks", ["project_id"], name: "index_tasks_on_project_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   default: "",    null: false
    t.string   "bio",                    default: "",    null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "admin",                  default: false, null: false
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  create_table "work_logs", force: true do |t|
    t.string   "description"
    t.string   "day"
    t.integer  "worked"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "work_logs", ["task_id"], name: "index_work_logs_on_task_id"

end
