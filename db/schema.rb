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

ActiveRecord::Schema.define(:version => 20120217014625) do

  create_table "achievement_sets", :force => true do |t|
    t.integer  "owner_id"
    t.datetime "expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "for"
  end

  add_index "achievement_sets", ["created_at"], :name => "index_achievement_sets_on_created_at"
  add_index "achievement_sets", ["for", "owner_id"], :name => "index_achievement_sets_on_for_and_owner_id"

  create_table "achievements", :force => true do |t|
    t.integer  "achievable_id"
    t.string   "achievable_type"
    t.integer  "user_id"
    t.integer  "achievement_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "achievements", ["achievable_id", "achievable_type"], :name => "index_achievements_on_achievable_id_and_achievable_type"
  add_index "achievements", ["achievement_set_id"], :name => "index_achievements_on_achievement_set_id"
  add_index "achievements", ["user_id"], :name => "index_achievements_on_user_id"

  create_table "actions", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actionable_type"
    t.integer  "actionable_id"
  end

  add_index "actions", ["actionable_id", "actionable_type", "name", "user_id"], :name => "index_actionable_name_user_id", :unique => true
  add_index "actions", ["created_at"], :name => "index_actions_on_created_at"
  add_index "actions", ["name"], :name => "index_actions_on_name"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "handle"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weight",     :default => 0
  end

  add_index "categories", ["handle"], :name => "index_categories_on_handle", :unique => true
  add_index "categories", ["weight"], :name => "index_categories_on_weight"

  create_table "collection_parts", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collection_parts", ["collection_id"], :name => "index_collection_parts_on_collection_id"
  add_index "collection_parts", ["product_id"], :name => "index_collection_parts_on_product_id"

  create_table "collections", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count", :default => 0
    t.integer  "actions_count",  :default => 0
    t.string   "name",           :default => ""
    t.string   "image_path"
    t.boolean  "is_processed",   :default => false
  end

  add_index "collections", ["user_id"], :name => "index_collections_on_user_id"

  create_table "comments", :force => true do |t|
    t.text     "data"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commentable_type"
    t.integer  "commentable_id"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.string   "third_party_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "contacts", ["name"], :name => "index_contacts_on_name"
  add_index "contacts", ["third_party_id"], :name => "index_contacts_on_third_party_id"
  add_index "contacts", ["user_id", "third_party_id"], :name => "index_contacts_on_user_id_and_third_party_id", :unique => true

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

  create_table "invites", :force => true do |t|
    t.integer  "user_id"
    t.string   "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invites", ["recipient_id"], :name => "index_invites_on_recipient_id"
  add_index "invites", ["user_id", "recipient_id"], :name => "index_invites_on_user_id_and_recipient_id", :unique => true

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

  create_table "products", :force => true do |t|
    t.string   "title"
    t.string   "handle"
    t.text     "endorsement"
    t.text     "source_url"
    t.text     "orig_image_url"
    t.boolean  "is_hosted",         :default => false
    t.string   "query"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "orig_thumb_url"
    t.integer  "comments_count",    :default => 0
    t.integer  "store_id"
    t.float    "price"
    t.integer  "category_id"
    t.string   "image_path"
    t.boolean  "is_processed",      :default => false
    t.boolean  "is_gift",           :default => false
    t.integer  "actions_count",     :default => 0
    t.integer  "source_product_id"
  end

  add_index "products", ["actions_count"], :name => "index_products_on_actions_count"
  add_index "products", ["category_id"], :name => "index_products_on_category_id"
  add_index "products", ["comments_count"], :name => "index_products_on_comments_count"
  add_index "products", ["created_at"], :name => "index_products_on_created_at"
  add_index "products", ["handle"], :name => "index_products_on_handle"
  add_index "products", ["is_processed"], :name => "index_products_on_is_processed"
  add_index "products", ["source_product_id"], :name => "index_products_on_source_product_id"
  add_index "products", ["store_id"], :name => "index_products_on_store_id"
  add_index "products", ["user_id"], :name => "index_products_on_user_id"

  create_table "searches", :force => true do |t|
    t.string   "query"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source"
  end

  add_index "searches", ["source"], :name => "index_searches_on_source"
  add_index "searches", ["user_id"], :name => "index_searches_on_user_id"

  create_table "settings", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "post_to_timeline", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["user_id"], :name => "index_settings_on_user_id", :unique => true

  create_table "shoppings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "store_id"
    t.integer  "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "products_count", :default => 0
  end

  add_index "shoppings", ["source"], :name => "index_shoppings_on_source"
  add_index "shoppings", ["store_id"], :name => "index_shoppings_on_store_id"
  add_index "shoppings", ["user_id", "store_id"], :name => "index_shoppings_on_user_id_and_store_id", :unique => true

  create_table "specialties", :force => true do |t|
    t.integer  "store_id"
    t.integer  "category_id"
    t.integer  "weight",      :default => 0
    t.boolean  "is_top",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "specialties", ["category_id"], :name => "index_specialties_on_category_id"
  add_index "specialties", ["store_id", "category_id"], :name => "index_specialties_on_store_id_and_category_id"
  add_index "specialties", ["store_id", "is_top"], :name => "index_specialties_on_store_id_and_is_top"
  add_index "specialties", ["weight"], :name => "index_specialties_on_weight"

  create_table "stores", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "products_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_approved",    :default => false
    t.string   "handle"
    t.string   "image_path"
    t.boolean  "is_processed",   :default => false
  end

  add_index "stores", ["handle"], :name => "index_stores_on_handle", :unique => true
  add_index "stores", ["is_approved"], :name => "index_stores_on_is_approved"
  add_index "stores", ["is_processed"], :name => "index_stores_on_is_processed"
  add_index "stores", ["name"], :name => "index_stores_on_name", :unique => true
  add_index "stores", ["products_count"], :name => "index_stores_on_products_count"

  create_table "ticker_actions", :force => true do |t|
    t.string   "og_action_id"
    t.string   "og_action_type"
    t.integer  "ticker_actionable_id"
    t.string   "ticker_actionable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.boolean  "is_admin",                  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
    t.string   "byline",                    :default => ""
    t.integer  "products_count",            :default => 0
    t.integer  "followings_count",          :default => 0
    t.integer  "inverse_followings_count",  :default => 0
    t.string   "handle"
    t.boolean  "has_contacts_mined",        :default => false
    t.integer  "collections_count",         :default => 0
  end

  add_index "users", ["birthday"], :name => "index_users_on_birthday"
  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["fb_user_id"], :name => "index_users_on_fb_user_id", :unique => true
  add_index "users", ["gender"], :name => "index_users_on_gender"
  add_index "users", ["handle"], :name => "index_users_on_handle", :unique => true
  add_index "users", ["has_contacts_mined"], :name => "index_users_on_has_contacts_mined"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token", :unique => true

end
