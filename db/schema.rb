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

ActiveRecord::Schema.define(:version => 20111202022914) do

  create_table "actions", :force => true do |t|
    t.integer  "product_id"
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "actions", ["product_id", "name", "user_id"], :name => "index_actions_on_product_id_and_name_and_user_id", :unique => true
  add_index "actions", ["user_id", "name"], :name => "index_actions_on_user_id_and_name"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "handle"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weight",     :default => 0
  end

  add_index "categories", ["handle"], :name => "index_categories_on_handle", :unique => true
  add_index "categories", ["weight"], :name => "index_categories_on_weight"

  create_table "comments", :force => true do |t|
    t.text     "data"
    t.integer  "user_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["product_id"], :name => "index_comments_on_product_id"
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

  create_table "followings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "follower_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",   :default => true
  end

  add_index "followings", ["follower_id"], :name => "index_followings_on_follower_id"
  add_index "followings", ["is_active"], :name => "index_followings_on_is_active"
  add_index "followings", ["user_id"], :name => "index_followings_on_user_id"

  create_table "invites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "recipient_id"
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
    t.boolean  "is_shared",         :default => false
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
  add_index "products", ["store_id"], :name => "index_products_on_store_id"
  add_index "products", ["user_id"], :name => "index_products_on_user_id"

  create_table "searches", :force => true do |t|
    t.string   "query"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], :name => "index_searches_on_user_id"

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
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["fb_user_id"], :name => "index_users_on_fb_user_id", :unique => true
  add_index "users", ["handle"], :name => "index_users_on_handle", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token", :unique => true

end
