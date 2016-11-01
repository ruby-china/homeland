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

ActiveRecord::Schema.define(version: 20160912124102) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorizations", force: :cascade do |t|
    t.string   "provider",                null: false
    t.string   "uid",        limit: 1000, null: false
    t.integer  "user_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["provider", "uid"], name: "index_authorizations_on_provider_and_uid", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.text     "body",             null: false
    t.text     "body_html"
    t.integer  "user_id",          null: false
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
    t.index ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "devices", force: :cascade do |t|
    t.integer  "platform",        null: false
    t.integer  "user_id",         null: false
    t.string   "token",           null: false
    t.datetime "last_actived_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["user_id", "platform"], name: "index_devices_on_user_id_and_platform", using: :btree
    t.index ["user_id"], name: "index_devices_on_user_id", using: :btree
  end

  create_table "exception_logs", force: :cascade do |t|
    t.string   "title",      null: false
    t.text     "body",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name",                    null: false
    t.integer  "users_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_locations_on_name", using: :btree
  end

  create_table "new_notifications", force: :cascade do |t|
    t.integer  "user_id",            null: false
    t.integer  "actor_id"
    t.string   "notify_type",        null: false
    t.string   "target_type"
    t.integer  "target_id"
    t.string   "second_target_type"
    t.integer  "second_target_id"
    t.string   "third_target_type"
    t.integer  "third_target_id"
    t.datetime "read_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["user_id", "notify_type"], name: "index_new_notifications_on_user_id_and_notify_type", using: :btree
    t.index ["user_id"], name: "index_new_notifications_on_user_id", using: :btree
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "name",                     null: false
    t.string   "summary"
    t.integer  "section_id",               null: false
    t.integer  "sort",         default: 0, null: false
    t.integer  "topics_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["section_id"], name: "index_nodes_on_section_id", using: :btree
    t.index ["sort"], name: "index_nodes_on_sort", using: :btree
  end

  create_table "notes", force: :cascade do |t|
    t.string   "title",                         null: false
    t.text     "body",                          null: false
    t.integer  "user_id",                       null: false
    t.integer  "word_count",    default: 0,     null: false
    t.integer  "changes_count", default: 0,     null: false
    t.boolean  "publish",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_notes_on_user_id", using: :btree
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.bigint   "expires_in"
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.bigint   "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "level",        default: 0,  null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
  end

  create_table "page_versions", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.integer  "page_id",                null: false
    t.integer  "version",    default: 0, null: false
    t.string   "slug",                   null: false
    t.string   "title",                  null: false
    t.text     "desc",                   null: false
    t.text     "body",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["page_id", "version"], name: "index_page_versions_on_page_id_and_version", using: :btree
    t.index ["page_id"], name: "index_page_versions_on_page_id", using: :btree
  end

  create_table "pages", force: :cascade do |t|
    t.string   "slug",                           null: false
    t.string   "title",                          null: false
    t.text     "body",                           null: false
    t.text     "body_html"
    t.boolean  "locked",         default: false
    t.integer  "version",        default: 0,     null: false
    t.integer  "editor_ids",     default: [],    null: false, array: true
    t.integer  "word_count",     default: 0,     null: false
    t.integer  "changes_cout",   default: 1,     null: false
    t.integer  "comments_count", default: 0,     null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug"], name: "index_pages_on_slug", unique: true, using: :btree
  end

  create_table "photos", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "image",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_photos_on_user_id", using: :btree
  end

  create_table "replies", force: :cascade do |t|
    t.integer  "user_id",                         null: false
    t.integer  "topic_id",                        null: false
    t.text     "body",                            null: false
    t.text     "body_html"
    t.integer  "state",              default: 1,  null: false
    t.integer  "liked_user_ids",     default: [],              array: true
    t.integer  "likes_count",        default: 0
    t.integer  "mentioned_user_ids", default: [],              array: true
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action"
    t.string   "target_type"
    t.string   "target_id"
    t.index ["deleted_at"], name: "index_replies_on_deleted_at", using: :btree
    t.index ["topic_id", "deleted_at"], name: "index_replies_on_topic_id_and_deleted_at", using: :btree
    t.index ["topic_id"], name: "index_replies_on_topic_id", using: :btree
    t.index ["user_id"], name: "index_replies_on_user_id", using: :btree
  end

  create_table "sections", force: :cascade do |t|
    t.string   "name",                   null: false
    t.integer  "sort",       default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sort"], name: "index_sections_on_sort", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree
  end

  create_table "site_nodes", force: :cascade do |t|
    t.string   "name",                   null: false
    t.integer  "sort",       default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sort"], name: "index_site_nodes_on_sort", using: :btree
  end

  create_table "sites", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "site_node_id"
    t.string   "name",         null: false
    t.string   "url",          null: false
    t.string   "desc"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_sites_on_deleted_at", using: :btree
    t.index ["site_node_id", "deleted_at"], name: "index_sites_on_site_node_id_and_deleted_at", using: :btree
    t.index ["site_node_id"], name: "index_sites_on_site_node_id", using: :btree
    t.index ["url"], name: "index_sites_on_url", using: :btree
  end

  create_table "team_users", force: :cascade do |t|
    t.integer  "team_id",    null: false
    t.integer  "user_id",    null: false
    t.integer  "role"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "user_id"], name: "index_team_users_on_team_id_and_user_id", unique: true, using: :btree
    t.index ["team_id"], name: "index_team_users_on_team_id", using: :btree
    t.index ["user_id"], name: "index_team_users_on_user_id", using: :btree
  end

  create_table "topics", force: :cascade do |t|
    t.integer  "user_id",                               null: false
    t.integer  "node_id",                               null: false
    t.string   "title",                                 null: false
    t.text     "body",                                  null: false
    t.text     "body_html"
    t.integer  "last_reply_id"
    t.integer  "last_reply_user_id"
    t.string   "last_reply_user_login"
    t.string   "node_name"
    t.string   "who_deleted"
    t.integer  "last_active_mark"
    t.boolean  "lock_node",             default: false
    t.datetime "suggested_at"
    t.integer  "excellent",             default: 0
    t.datetime "replied_at"
    t.integer  "replies_count",         default: 0,     null: false
    t.integer  "likes_count",           default: 0
    t.integer  "follower_ids",          default: [],                 array: true
    t.integer  "liked_user_ids",        default: [],                 array: true
    t.integer  "mentioned_user_ids",    default: [],                 array: true
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.integer  "team_id"
    t.index ["deleted_at"], name: "index_topics_on_deleted_at", using: :btree
    t.index ["excellent"], name: "index_topics_on_excellent", using: :btree
    t.index ["last_active_mark"], name: "index_topics_on_last_active_mark", using: :btree
    t.index ["likes_count"], name: "index_topics_on_likes_count", using: :btree
    t.index ["node_id", "deleted_at"], name: "index_topics_on_node_id_and_deleted_at", using: :btree
    t.index ["node_id"], name: "index_topics_on_node_id", using: :btree
    t.index ["suggested_at"], name: "index_topics_on_suggested_at", using: :btree
    t.index ["team_id"], name: "index_topics_on_team_id", using: :btree
    t.index ["user_id"], name: "index_topics_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                                             null: false
    t.string   "name"
    t.string   "email",                                             null: false
    t.string   "email_md5",                                         null: false
    t.boolean  "email_public",                      default: false, null: false
    t.string   "location"
    t.integer  "location_id"
    t.string   "bio"
    t.string   "website"
    t.string   "company"
    t.string   "github"
    t.string   "twitter"
    t.string   "qq"
    t.string   "avatar"
    t.boolean  "verified",                          default: false, null: false
    t.boolean  "hr",                                default: false, null: false
    t.integer  "state",                             default: 1,     null: false
    t.string   "tagline"
    t.string   "co"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt",                     default: "",    null: false
    t.string   "persistence_token",                 default: "",    null: false
    t.string   "single_access_token",               default: "",    null: false
    t.string   "perishable_token",                  default: "",    null: false
    t.integer  "topics_count",                      default: 0,     null: false
    t.integer  "replies_count",                     default: 0,     null: false
    t.integer  "favorite_topic_ids",                default: [],                 array: true
    t.integer  "blocked_node_ids",                  default: [],                 array: true
    t.integer  "blocked_user_ids",                  default: [],                 array: true
    t.integer  "following_ids",                     default: [],                 array: true
    t.integer  "follower_ids",                      default: [],                 array: true
    t.string   "type",                   limit: 20
    t.integer  "failed_attempts",                   default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.integer  "team_users_count"
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["location"], name: "index_users_on_location", using: :btree
    t.index ["login"], name: "index_users_on_login", using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

end
