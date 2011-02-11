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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110211041644) do

  create_table "authorizations", :force => true do |t|
    t.string   "provider",                   :null => false
    t.string   "uid",        :limit => 1000, :null => false
    t.integer  "user_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["provider", "uid"], :name => "index_authorizations_on_provider_and_uid"

  create_table "counters", :force => true do |t|
    t.string "key",   :null => false
    t.string "value", :null => false
  end

  add_index "counters", ["key"], :name => "index_counters_on_key"

  create_table "nodes", :force => true do |t|
    t.string  "name",                        :null => false
    t.integer "section_id",                  :null => false
    t.integer "sort",         :default => 0, :null => false
    t.integer "topics_count", :default => 0, :null => false
    t.string  "summary"
  end

  add_index "nodes", ["section_id"], :name => "index_nodes_on_section_id"

  create_table "notes", :force => true do |t|
    t.string   "title",                       :null => false
    t.text     "body",                        :null => false
    t.integer  "user_id",                     :null => false
    t.integer  "word_count",   :default => 0, :null => false
    t.integer  "changes_cout", :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"

  create_table "photos", :force => true do |t|
    t.string   "title",                          :null => false
    t.string   "image_file_name",                :null => false
    t.integer  "image_file_size", :default => 0, :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "replies", :force => true do |t|
    t.integer  "topic_id",                  :null => false
    t.text     "body",                      :null => false
    t.integer  "user_id",                   :null => false
    t.integer  "state",      :default => 1, :null => false
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "replies", ["topic_id"], :name => "index_replies_on_topic_id"
  add_index "replies", ["user_id"], :name => "index_replies_on_user_id"

  create_table "sections", :force => true do |t|
    t.string  "name",                :null => false
    t.integer "sort", :default => 0, :null => false
  end

  add_index "sections", ["sort"], :name => "index_sections_on_sort"

  create_table "topics", :force => true do |t|
    t.string   "title",                             :null => false
    t.integer  "node_id",                           :null => false
    t.text     "body",                              :null => false
    t.integer  "user_id",                           :null => false
    t.integer  "replies_count",      :default => 0, :null => false
    t.integer  "last_reply_user_id"
    t.datetime "replied_at"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topics", ["node_id"], :name => "index_topics_on_node_id"
  add_index "topics", ["user_id"], :name => "index_topics_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                  :null => false
    t.string   "name",                                   :null => false
    t.string   "location"
    t.string   "bio"
    t.string   "website"
    t.string   "avatar_file_name"
    t.boolean  "verified",            :default => false, :null => false
    t.integer  "state",               :default => 1,     :null => false
    t.string   "qq"
    t.string   "tagline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crypted_password",    :default => "",    :null => false
    t.string   "password_salt",       :default => "",    :null => false
    t.string   "persistence_token",   :default => "",    :null => false
    t.string   "single_access_token", :default => "",    :null => false
    t.string   "perishable_token",    :default => "",    :null => false
    t.integer  "login_count",         :default => 0,     :null => false
    t.integer  "failed_login_count",  :default => 0,     :null => false
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.integer  "notes_count",         :default => 0,     :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"

end
