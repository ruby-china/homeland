# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_06_091122) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", id: :serial, force: :cascade do |t|
    t.string "action_type", null: false
    t.string "action_option"
    t.string "target_type"
    t.integer "target_id"
    t.string "user_type"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["target_type", "target_id", "action_type"], name: "index_actions_on_target_type_and_target_id_and_action_type"
    t.index ["user_type", "user_id", "action_type"], name: "index_actions_on_user_type_and_user_id_and_action_type"
  end

  create_table "authorizations", id: :serial, force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", limit: 1000, null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["provider", "uid"], name: "index_authorizations_on_provider_and_uid"
  end

  create_table "columns", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "cover"
    t.integer "user_id", null: false
    t.string "who_deleted"
    t.integer "modified_admin_id"
    t.integer "likes_count", default: 0
    t.datetime "suggested_at"
    t.datetime "deleted_at"
    t.string "slug", null: false
    t.datetime "unseal_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "followers_count", default: 0
    t.integer "articles_count", default: 0, null: false
    t.index ["likes_count"], name: "index_columns_on_likes_count"
    t.index ["name"], name: "index_columns_on_name"
    t.index ["suggested_at"], name: "index_columns_on_suggested_at"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "body", null: false
    t.integer "user_id", null: false
    t.string "commentable_type"
    t.integer "commentable_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "devices", id: :serial, force: :cascade do |t|
    t.integer "platform", null: false
    t.integer "user_id", null: false
    t.string "token", null: false
    t.datetime "last_actived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "exception_tracks", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "github_statistics", force: :cascade do |t|
    t.string "github_user"
    t.string "testerhome_user"
    t.integer "ttf_contribution"
    t.integer "monthly_contribution"
    t.integer "discovery_contribution"
    t.date "data_of_month"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_of_month"], name: "index_github_statistics_on_data_of_month"
    t.index ["github_user"], name: "index_github_statistics_on_github_user"
    t.index ["testerhome_user"], name: "index_github_statistics_on_testerhome_user"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "users_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_locations_on_name"
  end

  create_table "nodes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "summary"
    t.integer "section_id", null: false
    t.integer "sort", default: 0, null: false
    t.integer "topics_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["section_id"], name: "index_nodes_on_section_id"
    t.index ["sort"], name: "index_nodes_on_sort"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.integer "user_id", null: false
    t.integer "word_count", default: 0, null: false
    t.integer "changes_count", default: 0, null: false
    t.boolean "publish", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "actor_id"
    t.string "notify_type", null: false
    t.string "target_type"
    t.integer "target_id"
    t.string "second_target_type"
    t.integer "second_target_id"
    t.string "third_target_type"
    t.integer "third_target_id"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.bigint "expires_in"
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.bigint "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "owner_id"
    t.string "owner_type"
    t.integer "level", default: 0, null: false
    t.boolean "confidential", default: true, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "page_versions", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "page_id", null: false
    t.integer "version", default: 0, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.text "desc", null: false
    t.text "body", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["page_id"], name: "index_page_versions_on_page_id"
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "image", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.jsonb "contacts", default: {}, null: false
    t.jsonb "rewards", default: {}, null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "replies", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id", null: false
    t.text "body", null: false
    t.integer "state", default: 1, null: false
    t.integer "likes_count", default: 0
    t.integer "mentioned_user_ids", default: [], array: true
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "action"
    t.string "target_type"
    t.string "target_id"
    t.integer "reply_to_id"
    t.integer "real_user_id"
    t.integer "anonymous", default: 0, null: false
    t.boolean "exposed_to_author_only", default: false, null: false
    t.datetime "suggested_at"
    t.index ["deleted_at"], name: "index_replies_on_deleted_at"
    t.index ["topic_id"], name: "index_replies_on_topic_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "search_documents", force: :cascade do |t|
    t.string "searchable_type", limit: 32, null: false
    t.integer "searchable_id", null: false
    t.tsvector "tokens"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_search_documents_on_searchable_type_and_searchable_id", unique: true
    t.index ["tokens"], name: "index_search_documents_on_tokens", using: :gin
  end

  create_table "sections", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "sort", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sort"], name: "index_sections_on_sort"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "team_users", id: :serial, force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "user_id", null: false
    t.integer "role"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_users_on_team_id"
    t.index ["user_id"], name: "index_team_users_on_user_id"
  end

  create_table "tip_offs", force: :cascade do |t|
    t.integer "reporter_id"
    t.string "reporter_email"
    t.string "tip_off_type"
    t.string "body"
    t.datetime "create_time"
    t.string "content_url"
    t.string "content_author_id"
    t.integer "follower_id"
    t.datetime "follow_time"
    t.string "follow_result"
    t.datetime "deleted_at"
    t.index ["reporter_id"], name: "index_tip_offs_on_reporter_id"
  end

  create_table "topics", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "node_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.integer "last_reply_id"
    t.integer "last_reply_user_id"
    t.string "last_reply_user_login"
    t.string "node_name"
    t.string "who_deleted"
    t.integer "last_active_mark"
    t.boolean "lock_node", default: false
    t.datetime "suggested_at"
    t.integer "grade", default: 0
    t.datetime "replied_at"
    t.integer "replies_count", default: 0, null: false
    t.integer "likes_count", default: 0
    t.integer "mentioned_user_ids", default: [], array: true
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.integer "team_id"
    t.integer "real_user_id"
    t.boolean "draft", default: true, null: false
    t.string "type"
    t.boolean "article_public", default: true, null: false
    t.integer "column_id"
    t.integer "modified_admin_id"
    t.boolean "cannot_be_shared", default: false
    t.index ["deleted_at"], name: "index_topics_on_deleted_at"
    t.index ["grade"], name: "index_topics_on_grade"
    t.index ["last_active_mark"], name: "index_topics_on_last_active_mark"
    t.index ["last_reply_id"], name: "index_topics_on_last_reply_id"
    t.index ["likes_count"], name: "index_topics_on_likes_count"
    t.index ["node_id", "deleted_at"], name: "index_topics_on_node_id_and_deleted_at"
    t.index ["suggested_at"], name: "index_topics_on_suggested_at"
    t.index ["team_id"], name: "index_topics_on_team_id"
    t.index ["user_id"], name: "index_topics_on_user_id"
  end

  create_table "user_ssos", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "uid", null: false
    t.string "username"
    t.string "email"
    t.string "name"
    t.string "avatar_url"
    t.text "last_payload", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_user_ssos_on_uid", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "login", limit: 100, null: false
    t.string "name", limit: 100
    t.string "email", null: false
    t.string "email_md5", null: false
    t.boolean "email_public", default: false, null: false
    t.string "location"
    t.integer "location_id"
    t.string "bio"
    t.string "website"
    t.string "company"
    t.string "github"
    t.string "twitter"
    t.string "avatar"
    t.integer "state", default: 1, null: false
    t.string "tagline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "password_salt", default: "", null: false
    t.string "persistence_token", default: "", null: false
    t.string "single_access_token", default: "", null: false
    t.string "perishable_token", default: "", null: false
    t.integer "topics_count", default: 0, null: false
    t.integer "replies_count", default: 0, null: false
    t.integer "follower_ids", default: [], array: true
    t.string "type", limit: 20
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "team_users_count"
    t.integer "followers_count", default: 0
    t.integer "following_count", default: 0
    t.integer "columns_count", default: 0
    t.index "lower((login)::text) varchar_pattern_ops", name: "index_users_on_lower_login_varchar_pattern_ops"
    t.index "lower((name)::text) varchar_pattern_ops", name: "index_users_on_lower_name_varchar_pattern_ops"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["location"], name: "index_users_on_location"
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
