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

ActiveRecord::Schema.define(:version => 20121028015724) do

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "purchase_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["purchase_id"], :name => "index_comments_on_purchase_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.string   "third_party_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "weight",         :default => 0
  end

  add_index "contacts", ["name"], :name => "index_contacts_on_name"
  add_index "contacts", ["third_party_id"], :name => "index_contacts_on_third_party_id"
  add_index "contacts", ["user_id", "third_party_id"], :name => "index_contacts_on_user_id_and_third_party_id", :unique => true
  add_index "contacts", ["weight"], :name => "index_contacts_on_weight"

  create_table "crawl_data", :force => true do |t|
    t.integer  "store_id"
    t.boolean  "active",       :default => false
    t.string   "launch_url"
    t.datetime "crawled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "use_og_image", :default => false
  end

  add_index "crawl_data", ["active"], :name => "index_crawl_data_on_active"
  add_index "crawl_data", ["crawled_at"], :name => "index_crawl_data_on_crawled_at"
  add_index "crawl_data", ["store_id"], :name => "index_crawl_data_on_store_id", :unique => true

  create_table "email_parse_data", :force => true do |t|
    t.integer  "store_id"
    t.boolean  "is_active",  :default => false
    t.string   "emails"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_parse_data", ["is_active"], :name => "index_email_parse_data_on_is_active"
  add_index "email_parse_data", ["store_id"], :name => "index_email_parse_data_on_store_id", :unique => true

  create_table "emails", :force => true do |t|
    t.integer  "recipient_id"
    t.integer  "sender_id"
    t.integer  "emailable_id"
    t.string   "emailable_type"
    t.string   "message_id"
    t.string   "request_id"
    t.integer  "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["emailable_id", "emailable_type"], :name => "index_emails_on_emailable_id_and_emailable_type"
  add_index "emails", ["message_id"], :name => "index_emails_on_message_id", :unique => true
  add_index "emails", ["purpose"], :name => "index_emails_on_purpose"
  add_index "emails", ["recipient_id"], :name => "index_emails_on_recipient_id"
  add_index "emails", ["request_id"], :name => "index_emails_on_request_id", :unique => true
  add_index "emails", ["sender_id"], :name => "index_emails_on_sender_id"

  create_table "followings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "follower_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",   :default => true
    t.integer  "source"
  end

  add_index "followings", ["created_at"], :name => "index_followings_on_created_at"
  add_index "followings", ["follower_id"], :name => "index_followings_on_follower_id"
  add_index "followings", ["is_active"], :name => "index_followings_on_is_active"
  add_index "followings", ["source"], :name => "index_followings_on_source"
  add_index "followings", ["user_id"], :name => "index_followings_on_user_id"

  create_table "health_reports", :force => true do |t|
    t.integer  "service"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "health_reports", ["service"], :name => "index_health_reports_on_service"

  create_table "invites", :force => true do |t|
    t.integer  "user_id"
    t.string   "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "platform",       :default => 0
    t.string   "recipient_name"
    t.string   "message"
  end

  add_index "invites", ["platform"], :name => "index_invites_on_platform"
  add_index "invites", ["recipient_id"], :name => "index_invites_on_recipient_id"
  add_index "invites", ["user_id", "recipient_id"], :name => "index_invites_on_user_id_and_recipient_id"

  create_table "likes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "purchase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "likes", ["purchase_id", "user_id"], :name => "index_likes_on_purchase_id_and_user_id", :unique => true
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "entity"
    t.string   "event"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.string   "image_url"
    t.integer  "identifier"
    t.string   "details"
    t.boolean  "unread",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["identifier"], :name => "index_notifications_on_identifier"
  add_index "notifications", ["resource_id", "resource_type"], :name => "index_notifications_on_resource_id_and_resource_type"
  add_index "notifications", ["updated_at"], :name => "index_notifications_on_updated_at"
  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "products", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "source_url"
    t.text     "orig_image_url"
    t.string   "orig_image_url_hash"
    t.string   "image_path"
    t.boolean  "is_processed",        :default => false
    t.integer  "store_id"
    t.string   "external_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["is_processed"], :name => "index_products_on_is_processed"
  add_index "products", ["orig_image_url_hash"], :name => "index_products_on_orig_image_url_hash", :unique => true
  add_index "products", ["store_id"], :name => "index_products_on_store_id"

  create_table "purchase_emails", :force => true do |t|
    t.integer  "purchase_id"
    t.string   "message_id"
    t.integer  "provider"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "purchase_emails", ["purchase_id"], :name => "index_purchase_emails_on_purchase_id", :unique => true

  create_table "purchases", :force => true do |t|
    t.string   "title"
    t.string   "handle"
    t.text     "endorsement"
    t.text     "source_url"
    t.text     "orig_image_url"
    t.string   "query"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "orig_thumb_url"
    t.integer  "store_id"
    t.string   "image_path"
    t.boolean  "is_processed",       :default => false
    t.integer  "source_purchase_id"
    t.integer  "suggestion_id"
    t.string   "fb_action_id"
    t.integer  "product_id"
    t.string   "tweet_id"
    t.string   "tumblr_post_id"
    t.boolean  "is_special",         :default => false
    t.integer  "source",             :default => 0
    t.boolean  "is_approved",        :default => true
    t.datetime "bought_at"
  end

  add_index "purchases", ["bought_at"], :name => "index_purchases_on_bought_at"
  add_index "purchases", ["created_at"], :name => "index_purchases_on_created_at"
  add_index "purchases", ["handle"], :name => "index_purchases_on_handle"
  add_index "purchases", ["is_approved"], :name => "index_purchases_on_is_approved"
  add_index "purchases", ["is_processed"], :name => "index_purchases_on_is_processed"
  add_index "purchases", ["is_special"], :name => "index_purchases_on_is_special"
  add_index "purchases", ["store_id"], :name => "index_purchases_on_store_id"
  add_index "purchases", ["suggestion_id"], :name => "index_purchases_on_suggestion_id"
  add_index "purchases", ["user_id"], :name => "index_purchases_on_user_id"

  create_table "searches", :force => true do |t|
    t.text     "query"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source"
  end

  add_index "searches", ["source"], :name => "index_searches_on_source"
  add_index "searches", ["user_id"], :name => "index_searches_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "share_to_facebook", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "email_influencer",  :default => true
    t.boolean  "email_update",      :default => true
    t.boolean  "share_to_twitter",  :default => true
    t.boolean  "share_to_tumblr",   :default => false
    t.integer  "theme_id",          :default => 1
    t.boolean  "email_digest",      :default => true
    t.boolean  "email_follower",    :default => true
  end

  add_index "settings", ["user_id"], :name => "index_settings_on_user_id", :unique => true

  create_table "shoppings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "store_id"
    t.integer  "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchases_count", :default => 0
  end

  add_index "shoppings", ["purchases_count"], :name => "index_shoppings_on_purchases_count"
  add_index "shoppings", ["source"], :name => "index_shoppings_on_source"
  add_index "shoppings", ["store_id"], :name => "index_shoppings_on_store_id"
  add_index "shoppings", ["user_id", "store_id"], :name => "index_shoppings_on_user_id_and_store_id", :unique => true

  create_table "stores", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "purchases_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_approved",     :default => false
    t.string   "handle"
    t.string   "image_path"
    t.boolean  "is_processed",    :default => false
    t.string   "domain"
    t.string   "byline"
    t.text     "description"
    t.string   "favicon_path"
  end

  add_index "stores", ["handle"], :name => "index_stores_on_handle", :unique => true
  add_index "stores", ["is_approved"], :name => "index_stores_on_is_approved"
  add_index "stores", ["is_processed"], :name => "index_stores_on_is_processed"
  add_index "stores", ["name"], :name => "index_stores_on_name", :unique => true
  add_index "stores", ["purchases_count"], :name => "index_stores_on_purchases_count"

  create_table "suggestions", :force => true do |t|
    t.string   "title",                           :null => false
    t.string   "image_path"
    t.integer  "weight",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gender",           :default => 0
    t.string   "short_title"
    t.string   "small_image_path"
    t.string   "thing"
    t.string   "example"
  end

  add_index "suggestions", ["gender"], :name => "index_suggestions_on_gender"
  add_index "suggestions", ["thing"], :name => "index_suggestions_on_thing"
  add_index "suggestions", ["weight"], :name => "index_suggestions_on_weight"

  create_table "themes", :force => true do |t|
    t.string   "background_path"
    t.string   "background_tile_path"
    t.string   "background_body_class"
    t.integer  "weight",                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default",            :default => false
  end

  add_index "themes", ["weight"], :name => "index_themes_on_weight"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "email"
    t.datetime "birthday"
    t.string   "fb_user_id"
    t.string   "access_token"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "is_admin",                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
    t.string   "byline",                     :default => ""
    t.integer  "purchases_count",            :default => 0
    t.integer  "followings_count",           :default => 0
    t.integer  "inverse_followings_count",   :default => 0
    t.string   "handle"
    t.boolean  "has_contacts_mined",         :default => false
    t.integer  "shoppings_count",            :default => 0
    t.string   "tw_access_token"
    t.string   "tw_access_token_secret"
    t.string   "tw_user_id"
    t.datetime "visited_at"
    t.string   "tumblr_access_token"
    t.string   "tumblr_access_token_secret"
    t.string   "tumblr_user_id"
    t.string   "iphone_device_token"
    t.boolean  "is_special",                 :default => false
    t.integer  "unread_notifications_count", :default => 0
    t.string   "go_email"
    t.string   "go_token"
    t.string   "go_secret"
    t.text     "yh_token"
    t.string   "yh_secret"
    t.string   "yh_email"
    t.string   "yh_session_handle"
  end

  add_index "users", ["birthday"], :name => "index_users_on_birthday"
  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["fb_user_id"], :name => "index_users_on_fb_user_id", :unique => true
  add_index "users", ["followings_count"], :name => "index_users_on_followings_count"
  add_index "users", ["gender"], :name => "index_users_on_gender"
  add_index "users", ["handle"], :name => "index_users_on_handle", :unique => true
  add_index "users", ["has_contacts_mined"], :name => "index_users_on_has_contacts_mined"
  add_index "users", ["is_special"], :name => "index_users_on_is_special"
  add_index "users", ["purchases_count"], :name => "index_users_on_purchases_count"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token", :unique => true
  add_index "users", ["shoppings_count"], :name => "index_users_on_shoppings_count"
  add_index "users", ["tw_user_id"], :name => "index_users_on_tw_user_id", :unique => true
  add_index "users", ["updated_at"], :name => "index_users_on_updated_at"
  add_index "users", ["visited_at"], :name => "index_users_on_visited_at"

end
