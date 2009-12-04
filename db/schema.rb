# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090514182755) do

  create_table "attachments", :force => true do |t|
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename",     :null => false
    t.integer  "width"
    t.integer  "height"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["parent_id"], :name => "index_attachments_on_parent_id"

  create_table "comments", :force => true do |t|
    t.integer  "item_id",                      :null => false
    t.integer  "visit_id",                     :null => false
    t.text     "content",                      :null => false
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["item_id"], :name => "index_comments_on_item_id"
  add_index "comments", ["visit_id"], :name => "index_comments_on_visit_id"

  create_table "flag_types", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flags", :force => true do |t|
    t.integer  "item_id"
    t.integer  "comment_id"
    t.integer  "visit_id",                       :null => false
    t.integer  "flag_type_id",                   :null => false
    t.text     "content"
    t.boolean  "active",       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flags", ["comment_id"], :name => "index_flags_on_comment_id"
  add_index "flags", ["flag_type_id"], :name => "index_flags_on_flag_type_id"
  add_index "flags", ["item_id"], :name => "index_flags_on_item_id"
  add_index "flags", ["visit_id"], :name => "index_flags_on_visit_id"

  create_table "flickrs", :force => true do |t|
    t.integer  "item_id",      :null => false
    t.string   "title"
    t.integer  "num_comments"
    t.integer  "license_id"
    t.string   "posted"
    t.string   "lastupdate"
    t.string   "taken"
    t.text     "tags"
    t.string   "description"
    t.string   "username"
    t.integer  "photo_id"
    t.string   "longitude"
    t.string   "latitude"
    t.integer  "accuracy"
    t.string   "country"
    t.string   "region"
    t.string   "place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flickrs", ["item_id"], :name => "index_flickrs_on_item_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["code"], :name => "index_groups_on_code"

  create_table "groups_questions", :id => false, :force => true do |t|
    t.integer "group_id",    :null => false
    t.integer "question_id", :null => false
  end

  add_index "groups_questions", ["group_id"], :name => "index_groups_questions_on_group_id"
  add_index "groups_questions", ["question_id"], :name => "index_groups_questions_on_question_id"

  create_table "items", :force => true do |t|
    t.integer  "visit_id"
    t.integer  "attachment_id"
    t.integer  "item_id_ext",                      :null => false
    t.string   "description"
    t.string   "attribution"
    t.string   "external_link"
    t.boolean  "active",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tags"
  end

  add_index "items", ["attachment_id"], :name => "index_items_on_attachment_id"
  add_index "items", ["item_id_ext"], :name => "index_items_on_item_id_ext"

  create_table "items_prompts", :id => false, :force => true do |t|
    t.integer "item_id",   :null => false
    t.integer "prompt_id", :null => false
  end

  add_index "items_prompts", ["item_id", "prompt_id"], :name => "index_items_prompts_on_item_id_and_prompt_id"
  add_index "items_prompts", ["item_id"], :name => "index_items_prompts_on_item_id"
  add_index "items_prompts", ["prompt_id"], :name => "index_items_prompts_on_prompt_id"

  create_table "items_questions", :force => true do |t|
    t.integer "item_id",                    :null => false
    t.integer "question_id",                :null => false
    t.integer "position"
    t.integer "ratings",     :default => 0, :null => false
    t.integer "wins",        :default => 0, :null => false
    t.integer "losses",      :default => 0, :null => false
  end

  add_index "items_questions", ["item_id"], :name => "index_items_questions_on_item_id"
  add_index "items_questions", ["question_id"], :name => "index_items_questions_on_question_id"

  create_table "items_responses", :id => false, :force => true do |t|
    t.integer "item_id",     :null => false
    t.integer "response_id", :null => false
  end

  add_index "items_responses", ["item_id"], :name => "index_items_responses_on_item_id"
  add_index "items_responses", ["response_id"], :name => "index_items_responses_on_response_id"

  create_table "mailings", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "item_id"
    t.string   "name",                          :null => false
    t.string   "email",                         :null => false
    t.text     "message",                       :null => false
    t.boolean  "sent",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mail_type"
    t.integer  "visit_id",                      :null => false
  end

  add_index "mailings", ["user_id"], :name => "index_mailings_on_user_id"

  create_table "params", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "value",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "params", ["name"], :name => "index_params_on_name"

  create_table "profile_questions", :force => true do |t|
    t.integer  "profile_id", :null => false
    t.string   "name",       :null => false
    t.string   "value",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_questions", ["name"], :name => "index_profile_questions_on_name"
  add_index "profile_questions", ["profile_id"], :name => "index_profile_questions_on_profile_id"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.string   "locale"
    t.string   "country"
    t.datetime "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "prompts", :force => true do |t|
    t.integer  "question_id",                     :null => false
    t.integer  "user_id",                         :null => false
    t.integer  "visit_id"
    t.integer  "prompt_id_ext",                   :null => false
    t.boolean  "active",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prompts", ["active", "user_id", "question_id", "visit_id"], :name => "index_prompts_on_active_and_user_id_and_question_id_and_visit_id"
  add_index "prompts", ["active", "user_id", "question_id"], :name => "index_prompts_on_active_and_user_id_and_question_id"
  add_index "prompts", ["active"], :name => "index_prompts_on_active"
  add_index "prompts", ["prompt_id_ext"], :name => "index_prompts_on_prompt_id_ext"
  add_index "prompts", ["question_id"], :name => "index_prompts_on_question_id"
  add_index "prompts", ["user_id"], :name => "index_prompts_on_user_id"
  add_index "prompts", ["visit_id"], :name => "index_prompts_on_visit_id"

  create_table "questions", :force => true do |t|
    t.integer  "question_id_ext", :null => false
    t.string   "name",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "responses", :force => true do |t|
    t.integer  "visit_id",                          :null => false
    t.integer  "prompt_id",                         :null => false
    t.integer  "vote_id_ext",                       :null => false
    t.integer  "response_time",                     :null => false
    t.string   "ip_country_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",          :default => true
  end

  add_index "responses", ["active"], :name => "index_responses_on_active"
  add_index "responses", ["ip_country_code"], :name => "index_responses_on_ip_country_code"
  add_index "responses", ["prompt_id"], :name => "index_responses_on_prompt_id"
  add_index "responses", ["visit_id"], :name => "index_responses_on_visit_id"
  add_index "responses", ["vote_id_ext"], :name => "index_responses_on_vote_id_ext"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "stats", :force => true do |t|
    t.integer  "item_id",     :null => false
    t.integer  "group_id"
    t.integer  "question_id"
    t.integer  "ratings",     :null => false
    t.integer  "wins",        :null => false
    t.integer  "losses",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stats", ["group_id"], :name => "index_stats_on_group_id"
  add_index "stats", ["item_id"], :name => "index_stats_on_item_id"
  add_index "stats", ["question_id"], :name => "index_stats_on_question_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "trackings", :force => true do |t|
    t.integer  "visit_id",   :null => false
    t.string   "controller", :null => false
    t.string   "action",     :null => false
    t.string   "parameters"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "mouse"
  end

  create_table "translations", :force => true do |t|
    t.string   "value",        :null => false
    t.string   "locale",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "content_id",   :null => false
    t.string   "content_type", :null => false
  end

  add_index "translations", ["content_id"], :name => "index_translations_on_content_id"
  add_index "translations", ["content_type"], :name => "index_translations_on_content_type"
  add_index "translations", ["locale"], :name => "index_translations_on_locale"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.integer  "voter_id_ext"
    t.integer  "items_count"
    t.integer  "items_responses_count"
    t.integer  "responses_rank"
    t.integer  "responses_count"
    t.datetime "cached_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "visits", :force => true do |t|
    t.integer  "user_id"
    t.integer  "prompt_id"
    t.string   "locale"
    t.string   "ip_address",                              :null => false
    t.string   "ip_city"
    t.string   "ip_latitude"
    t.string   "ip_longitude"
    t.string   "ip_country_code"
    t.string   "ip_country_name"
    t.string   "ip_dma_code"
    t.string   "ip_area_code"
    t.string   "ip_region"
    t.string   "host"
    t.string   "user_agent"
    t.string   "request_uri"
    t.string   "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "lock",                 :default => false
    t.integer  "prompts_per_question"
  end

  add_index "visits", ["user_id"], :name => "index_visits_on_user_id"

end
