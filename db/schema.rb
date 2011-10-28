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

ActiveRecord::Schema.define(:version => 20111028214715) do

  create_table "comments", :force => true do |t|
    t.text     "data"
    t.integer  "user_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["product_id"], :name => "index_comments_on_product_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

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
    t.text     "website_url"
    t.text     "image_url"
    t.boolean  "is_hosted",      :default => false
    t.string   "query"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_shared",      :default => false
    t.string   "thumb_url"
    t.string   "category"
    t.integer  "comments_count", :default => 0
    t.integer  "store_id"
    t.float    "price"
  end

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
  end

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
    t.float    "products_price",            :default => 0.0
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token", :unique => true

end
