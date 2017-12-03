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

  create_table "identities", force: :cascade do |t|
    t.string   "provider",   limit: 255, null: false
    t.string   "uid",        limit: 255, null: false
    t.integer  "user_id",    limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true, using: :btree

  create_table "project_members", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,             null: false
    t.integer  "project_id", limit: 4,             null: false
    t.integer  "role",       limit: 4, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_members", ["project_id"], name: "index_project_members_on_project_id", using: :btree
  add_index "project_members", ["user_id", "project_id"], name: "index_project_members_on_user_id_and_project_id", unique: true, using: :btree
  add_index "project_members", ["user_id"], name: "index_project_members_on_user_id", using: :btree

  create_table "project_openings", force: :cascade do |t|
    t.integer  "project_id", limit: 4, null: false
    t.integer  "user_id",    limit: 4, null: false
    t.integer  "touched",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_openings", ["project_id"], name: "index_project_openings_on_project_id", using: :btree
  add_index "project_openings", ["user_id", "project_id"], name: "index_project_openings_on_user_id_and_project_id", unique: true, using: :btree
  add_index "project_openings", ["user_id"], name: "index_project_openings_on_user_id", using: :btree

  create_table "project_snapshots", force: :cascade do |t|
    t.integer  "project_id",         limit: 4, null: false
    t.integer  "task_count",         limit: 4
    t.integer  "original_estimate",  limit: 4
    t.integer  "work_logged",        limit: 4
    t.integer  "remaining_estimate", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_snapshots", ["project_id"], name: "index_project_snapshots_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "code",                    limit: 255,   default: "", null: false
    t.string   "name",                    limit: 255,   default: "", null: false
    t.text     "description",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
    t.string   "state",                   limit: 255
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "name",               limit: 255,   default: "", null: false
    t.text     "description",        limit: 65535
    t.integer  "original_estimate",  limit: 4
    t.integer  "remaining_estimate", limit: 4
    t.integer  "project_id",         limit: 4,                  null: false
    t.integer  "assignee_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iid",                limit: 4
  end

  add_index "tasks", ["assignee_id"], name: "index_tasks_on_assignee_id", using: :btree
  add_index "tasks", ["project_id"], name: "index_tasks_on_project_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   limit: 255, default: "",    null: false
    t.string   "bio",                    limit: 255, default: "",    null: false
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size",       limit: 4
    t.datetime "avatar_updated_at"
    t.boolean  "admin",                              default: false, null: false
    t.string   "authentication_token",   limit: 255
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "work_logs", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "day",         limit: 255
    t.integer  "worked",      limit: 4
    t.integer  "task_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "work_logs", ["task_id"], name: "index_work_logs_on_task_id", using: :btree

end
