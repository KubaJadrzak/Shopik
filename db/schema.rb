# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_24_133252) do
  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_id"], name: "index_cart_items_on_cart_id_and_product_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "price_at_purchase", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "uuid", null: false
    t.string "email", null: false
    t.string "state", null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.text "shipping_address", null: false
    t.datetime "ordered_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.index ["uuid"], name: "index_orders_on_uuid", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "state", default: "new", null: false
    t.string "reject_reason"
    t.string "issuer_response_code"
    t.string "behaviour"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", null: false
    t.string "payable_type"
    t.integer "payable_id"
    t.integer "saved_payment_method_id"
    t.integer "payment_method", null: false
    t.integer "cof"
    t.string "currency", default: "USD", null: false
    t.integer "kind", null: false
    t.string "espago_payment_id"
    t.string "response"
    t.string "espago_client_id"
    t.string "card_identifier"
    t.string "transaction_id"
    t.string "espago_payment_token"
    t.index ["card_identifier"], name: "index_payments_on_card_identifier"
    t.index ["payable_type", "payable_id"], name: "index_payments_on_payable"
    t.index ["saved_payment_method_id"], name: "index_payments_on_saved_payment_method_id"
    t.index ["state"], name: "index_payments_on_state"
    t.index ["uuid"], name: "index_payments_on_uuid", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "membership_price"
  end

  create_table "saved_payment_methods", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "company"
    t.string "last4"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "state", default: "unverified", null: false
    t.integer "month", null: false
    t.integer "year", null: false
    t.boolean "primary", default: false, null: false
    t.string "card_identifier"
    t.string "espago_client_id", null: false
    t.index ["card_identifier"], name: "index_saved_payment_methods_on_card_identifier"
    t.index ["user_id"], name: "index_saved_payment_methods_on_user_id"
    t.index ["uuid"], name: "index_saved_payment_methods_on_uuid", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.string "state", default: "New", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", default: "4.99", null: false
    t.string "uuid", null: false
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
    t.index ["uuid"], name: "index_subscriptions_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.boolean "auto_renew", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "saved_payment_methods", on_delete: :nullify
  add_foreign_key "saved_payment_methods", "users"
  add_foreign_key "subscriptions", "users"
end
