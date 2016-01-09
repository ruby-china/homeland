# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you"ll amass, the slower it"ll run and the greater likelihood for issues).
#
# It"s strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(version: 20160103132805) do
  create_table "authorizations", force: true do |t|
    t.string      "provider", null: false
    t.string      "uid", limit: 1000, null: false
    t.integer     "user_id", null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "authorizations", %w(provider uid), name: "index_authorizations_on_provider_and_uid"

  create_table "comments", force: true do |t|
    t.text        "body", null: false
    t.text        "body_html", null: false
    t.integer     "user_id", null: false
    t.string      "commentable_type"
    t.integer     "commentable_id"
    t.datetime    "deleted_at"
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"
  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type"


  create_table "exception_logs", force: true do |t|
    t.string      "title", null: false
    t.text        "body", null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string      "name", null: false
    t.integer     "users_count", default: 0, null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "locations", ["name"], name: "index_locations_on_name"

  create_table "nodes", force: true do |t|
    t.string      "name", null: false
    t.string      "summary"
    t.integer     "section_id", null: false
    t.integer     "sort",         default: 0, null: false
    t.integer     "topics_count", default: 0, null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "nodes", ["section_id"], name: "index_nodes_on_section_id"

  create_table "notes", force: true do |t|
    t.string      "title", null: false
    t.text        "body", null: false
    t.integer     "user_id", null: false
    t.integer     "word_count",   default: 0, null: false
    t.integer     "changes_count", default: 0, null: false
    t.boolean     "publish", default: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "notes", ["user_id"], name: "index_notes_on_user_id"

  create_table "notifications", force: true do |t|
    t.integer     "user_id", null: false
    t.boolean     "read", default: false
    t.string      "type"
    t.integer     "follower_id"
    t.integer     "node_id"
    t.integer     "topic_id"
    t.integer     "reply_id"
    t.integer     "mentionable_id"
    t.string      "mentionable_type"
    t.integer     "mentioned_user_ids", array: true, default: []
    t.integer     "changes_count", default: 0, null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "notifications", ["read"], name: "index_notifications_on_read"
  add_index "notifications", ["user_id", "read"], name: "index_notifications_on_user_id_and_read"

  create_table "pages", force: true do |t|
    t.string      "slug", null: false
    t.string      "title", null: false
    t.text        "body", null: false
    t.text        "body_html", null: false
    t.integer     "user_id", null: false
    t.boolean     "locked", default: false
    t.integer     "version", default: 0, null: false
    t.integer     "editor_ids",  array: true, null: false
    t.integer     "word_count",   default: 0, null: false
    t.integer     "changes_cout", default: 1, null: false
    t.integer     "comments_count", default: 0, null: false
    t.datetime    "deleted_at"
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "pages", ["user_id"], name: "index_pages_on_user_id"
  add_index "pages", ["slug"], name: "index_pages_on_slug"

  create_table "page_versions", force: true do |t|
    t.integer     "user_id", null: false
    t.integer     "page_id", null: false
    t.integer     "version", default: 0, null: false
    t.string      "slug", null: false
    t.string      "title", null: false
    t.text        "desc", null: false
    t.text        "body", null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end
  add_index "page_versions", ["page_id"], name: "index_page_versions_on_page_id"
  add_index "page_versions", ["page_id", "version"], name: "index_page_versions_on_page_id_and_version"

  create_table "photos", force: true do |t|
    t.integer     "user_id"
    t.string      "image",                null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  create_table "replies", force: true do |t|
    t.integer     "user_id", null: false
    t.integer     "topic_id", null: false
    t.text        "body", null: false
    t.text        "body_html", null: false
    t.integer     "state", default: 1, null: false
    t.integer     "liked_user_ids", array: true, default: []
    t.integer     "likes_count", default: 0
    t.integer     "mentioned_user_ids", array: true, default: []
    t.datetime    "deleted_at"
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "replies", ["topic_id"], name: "index_replies_on_topic_id"
  add_index "replies", ["user_id"], name: "index_replies_on_user_id"

  create_table "sites", force: true do |t|
    t.integer     "site_node_id"
    t.string      "name", null: false
    t.string      "url", null: false
    t.string      "desc", null: false
    t.datetime    "deleted_at"
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "sites", ["url"], name: "index_sites_on_url"
  add_index "sites", ["site_node_id"], name: "index_sites_on_site_node_id"

  create_table "site_configs", force: true do |t|
    t.string      "key", null: false
    t.text        "value", null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "site_configs", ["key"], name: "index_site_configs_on_key"

  create_table "site_nodes", force: true do |t|
    t.string      "name", null: false
    t.integer     "sort", default: 0, null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "site_nodes", ["sort"], name: "index_site_nodes_on_sort"

  create_table "sections", force: true do |t|
    t.string      "name", null: false
    t.integer     "sort", default: 0, null: false
    t.datetime    "created_at"
    t.datetime    "updated_at"
  end

  add_index "sections", ["sort"], name: "index_sections_on_sort"

  create_table "topics", force: true do |t|
    t.integer   "user_id", null: false
    t.integer   "node_id", null: false
    t.string    "title", null: false
    t.text      "body", null: false
    t.text      "body_html", null: false
    t.integer   "last_reply_id"
    t.string    "last_reply_login"
    t.string    "node_name"
    t.string    "who_deleted"
    t.integer   "last_active_mark"
    t.boolean   "lock_node", default: false
    t.datetime  "suggested_at"
    t.integer   "excellent", default: 0
    t.datetime  "replied_at"
    t.integer   "replies_count", default: 0, null: false
    t.integer   "likes_count", default: 0, null: false
    t.integer   "follower_ids", array: true, default: []
    t.integer   "liked_user_ids", array: true, default: []
    t.integer   "likes_count", default: 0
    t.integer   "mentioned_user_ids", array: true, default: []
    t.datetime  "deleted_at"
    t.datetime  "created_at"
    t.datetime  "updated_at"
  end

  add_index "topics", ["node_id"], name: "index_topics_on_node_id"
  add_index "topics", ["user_id"], name: "index_topics_on_user_id"
  add_index "topics", ["likes_count"], name: "index_topics_on_likes_count"
  add_index "topics", ["suggested_at"], name: "index_topics_on_suggested_at"
  add_index "topics", ["excellent"], name: "index_topics_on_excellent"
  add_index "topics", ["last_active_mark"], name: "index_topics_on_last_active_mark"

  create_table "users", force: true do |t|
    t.string      "login",                                  null: false
    t.string      "name",                                   null: false
    t.string      "email",                                  null: false
    t.string      "email_md5",                              null: false
    t.boolean     "email_public",            default: false, null: false
    t.string      "location"
    t.integer     "location_id"
    t.string      "bio"
    t.string      "website"
    t.string      "company"
    t.string      "github"
    t.string      "twitter"
    t.string      "qq"
    t.string      "avatar"
    t.boolean     "verified",            default: false, null: false
    t.boolean     "hr",            default: false, null: false
    t.integer     "state",               default: 1,     null: false
    t.string      "tagline"
    t.string      "co"
    t.datetime    "created_at"
    t.datetime    "updated_at"
    t.string      "encrypted_password",     default: "", null: false
    t.string      "reset_password_token"
    t.datetime    "reset_password_sent_at"
    t.datetime    "remember_created_at"
    t.integer     "sign_in_count",          default: 0,  null: false
    t.datetime    "current_sign_in_at"
    t.datetime    "last_sign_in_at"
    t.string      "current_sign_in_ip"
    t.string      "last_sign_in_ip"
    t.string      "password_salt",       default: "",    null: false
    t.string      "persistence_token",   default: "",    null: false
    t.string      "single_access_token", default: "",    null: false
    t.string      "perishable_token",    default: "",    null: false
    t.integer     "topics_count", default: 0, null: false
    t.integer     "replies_count", default: 0, null: false
    t.string      "private_token"
    t.integer     "favorite_topic_ids", array: true, default: []
    t.integer     "blocked_node_ids", array: true, default: []
    t.integer     "blocked_user_ids", array: true, default: []
    t.integer     "following_ids", array: true, default: []
    t.integer     "follower_ids", array: true, default: []

  end

  add_index "users", ["login"], name: "index_users_on_login"
  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["location"], name: "index_users_on_location"
  add_index "users", ["private_token"], name: "index_users_on_private_token"
end
