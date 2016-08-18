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

ActiveRecord::Schema.define(version: 20160521004301) do

  create_table "SequelizeMeta", primary_key: "name", force: :cascade do |t|
  end

  add_index "sequelizemeta", ["name"], name: "SequelizeMeta_name_unique", unique: true, using: :btree
  add_index "sequelizemeta", ["name"], name: "name", unique: true, using: :btree

  create_table "accounts", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "name",        limit: 255
    t.string   "owner_key",   limit: 255
    t.string   "active_key",  limit: 255
    t.string   "posting_key", limit: 255
    t.string   "memo_key",    limit: 255
    t.string   "referrer",    limit: 255
    t.string   "refcode",     limit: 255
    t.string   "remote_ip",   limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "accounts", ["active_key"], name: "accounts_active_key", using: :btree
  add_index "accounts", ["memo_key"], name: "accounts_memo_key", using: :btree
  add_index "accounts", ["name"], name: "accounts_name", unique: true, using: :btree
  add_index "accounts", ["owner_key"], name: "accounts_owner_key", using: :btree
  add_index "accounts", ["posting_key"], name: "accounts_posting_key", using: :btree
  add_index "accounts", ["user_id"], name: "user_id", using: :btree

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.string   "provider",         limit: 255
    t.string   "provider_user_id", limit: 255
    t.string   "name",             limit: 255
    t.string   "email",            limit: 255
    t.boolean  "verified"
    t.integer  "score",            limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "identities", ["email"], name: "identities_email", unique: true, using: :btree
  add_index "identities", ["provider_user_id"], name: "identities_uid", unique: true, using: :btree
  add_index "identities", ["user_id"], name: "user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "email",         limit: 255
    t.string   "uid",           limit: 64
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
    t.datetime "birthday"
    t.string   "gender",        limit: 8
    t.string   "picture_small", limit: 255
    t.string   "picture_large", limit: 255
    t.integer  "facebook_id",   limit: 8
    t.integer  "location_id",   limit: 8
    t.string   "location_name", limit: 255
    t.string   "locale",        limit: 12
    t.integer  "timezone",      limit: 4
    t.boolean  "verified"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "waiting_list"
    t.string   "remote_ip",     limit: 255
  end

  add_index "users", ["email"], name: "users_email", unique: true, using: :btree
  add_index "users", ["facebook_id"], name: "users_facebook_id", unique: true, using: :btree
  add_index "users", ["uid"], name: "users_uid", unique: true, using: :btree

  create_table "web_events", force: :cascade do |t|
    t.string   "event_type",   limit: 12
    t.string   "value",        limit: 255
    t.integer  "user_id",      limit: 4
    t.string   "uid",          limit: 32
    t.string   "account_name", limit: 64
    t.boolean  "first_visit"
    t.boolean  "new_session"
    t.string   "ip",           limit: 48
    t.string   "refurl",       limit: 255
    t.string   "user_agent",   limit: 255
    t.integer  "status",       limit: 4
    t.string   "city",         limit: 64
    t.string   "state",        limit: 64
    t.string   "country",      limit: 64
    t.string   "channel",      limit: 64
    t.string   "referrer",     limit: 64
    t.string   "refcode",      limit: 64
    t.string   "campaign",     limit: 64
    t.integer  "adgroupid",    limit: 4
    t.integer  "adid",         limit: 4
    t.integer  "keywordid",    limit: 4
    t.integer  "messageid",    limit: 4
    t.datetime "created_at",               null: false
  end

  add_index "web_events", ["account_name"], name: "web_events_account_name", using: :btree
  add_index "web_events", ["event_type"], name: "web_events_event_type", using: :btree
  add_index "web_events", ["uid"], name: "web_events_uid", using: :btree
  add_index "web_events", ["user_id"], name: "web_events_user_id", using: :btree

  add_foreign_key "accounts", "users", name: "accounts_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "identities", "users", name: "identities_ibfk_1", on_update: :cascade, on_delete: :cascade
end
