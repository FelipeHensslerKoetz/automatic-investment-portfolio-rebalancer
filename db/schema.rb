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

ActiveRecord::Schema.define(version: 2024_07_09_000408) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "asset_prices", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.bigint "partner_resource_id"
    t.string "ticker_symbol", null: false
    t.bigint "currency_id", null: false
    t.decimal "price", null: false
    t.datetime "last_sync_at", null: false
    t.datetime "reference_date", null: false
    t.datetime "scheduled_at"
    t.string "status", null: false
    t.string "error_message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["asset_id", "partner_resource_id"], name: "index_asset_prices_on_asset_id_and_partner_resource_id", unique: true
    t.index ["asset_id"], name: "index_asset_prices_on_asset_id"
    t.index ["currency_id"], name: "index_asset_prices_on_currency_id"
    t.index ["partner_resource_id"], name: "index_asset_prices_on_partner_resource_id"
  end

  create_table "assets", force: :cascade do |t|
    t.string "ticker_symbol", null: false
    t.string "name", null: false
    t.string "kind"
    t.boolean "custom", default: false, null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ticker_symbol"], name: "index_assets_on_ticker_symbol", unique: true
    t.index ["user_id"], name: "index_assets_on_user_id"
  end

  create_table "automatic_rebalance_options", force: :cascade do |t|
    t.bigint "investment_portfolio_id", null: false
    t.string "kind", null: false
    t.integer "recurrence_days"
    t.date "start_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["investment_portfolio_id"], name: "index_automatic_rebalance_options_on_investment_portfolio_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_currencies_on_code", unique: true
  end

  create_table "currency_parities", force: :cascade do |t|
    t.bigint "currency_from_id", null: false
    t.bigint "currency_to_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["currency_from_id"], name: "index_currency_parities_on_currency_from_id"
    t.index ["currency_to_id"], name: "index_currency_parities_on_currency_to_id"
  end

  create_table "currency_parity_exchange_rates", force: :cascade do |t|
    t.bigint "currency_parity_id", null: false
    t.decimal "exchange_rate", null: false
    t.datetime "last_sync_at", null: false
    t.datetime "reference_date", null: false
    t.bigint "partner_resource_id", null: false
    t.string "status", null: false
    t.datetime "scheduled_at"
    t.string "error_message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["currency_parity_id", "partner_resource_id"], name: "currency_parity_and_partner_resource_index", unique: true
    t.index ["currency_parity_id"], name: "index_currency_parity_exchange_rates_on_currency_parity_id"
    t.index ["partner_resource_id"], name: "index_currency_parity_exchange_rates_on_partner_resource_id"
  end

  create_table "customer_support_item_messages", force: :cascade do |t|
    t.bigint "customer_support_item_id", null: false
    t.bigint "user_id", null: false
    t.string "message", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_support_item_id"], name: "idx_customer_support_item_messages_on_customer_support_item_id"
    t.index ["user_id"], name: "index_customer_support_item_messages_on_user_id"
  end

  create_table "customer_support_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "description", null: false
    t.string "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_customer_support_items_on_user_id"
  end

  create_table "investment_portfolio_assets", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.bigint "investment_portfolio_id", null: false
    t.decimal "target_allocation_weight_percentage", null: false
    t.decimal "quantity", default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "target_variation_limit_percentage", null: false
    t.index ["asset_id", "investment_portfolio_id"], name: "asset_id_and_investment_portfolio_id_index", unique: true
    t.index ["asset_id"], name: "index_investment_portfolio_assets_on_asset_id"
    t.index ["investment_portfolio_id"], name: "index_investment_portfolio_assets_on_investment_portfolio_id"
  end

  create_table "investment_portfolios", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_investment_portfolios_on_user_id"
  end

  create_table "logs", force: :cascade do |t|
    t.string "kind", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "partner_resources", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "description"
    t.string "url"
    t.bigint "partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_partner_resources_on_name", unique: true
    t.index ["partner_id"], name: "index_partner_resources_on_partner_id"
    t.index ["slug"], name: "index_partner_resources_on_slug", unique: true
  end

  create_table "partners", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug", null: false
    t.index ["name"], name: "index_partners_on_name", unique: true
    t.index ["slug"], name: "index_partners_on_slug", unique: true
  end

  create_table "rebalance_orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "investment_portfolio_id", null: false
    t.string "status", null: false
    t.string "kind", null: false
    t.decimal "amount", null: false
    t.string "error_message"
    t.date "scheduled_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "created_by_system", default: false
    t.index ["investment_portfolio_id"], name: "index_rebalance_orders_on_investment_portfolio_id"
    t.index ["user_id"], name: "index_rebalance_orders_on_user_id"
  end

  create_table "rebalances", force: :cascade do |t|
    t.bigint "rebalance_order_id", null: false
    t.jsonb "before_state", null: false
    t.jsonb "after_state", null: false
    t.jsonb "details", null: false
    t.jsonb "recommended_actions", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["rebalance_order_id"], name: "index_rebalances_on_rebalance_order_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email", default: "", null: false
    t.boolean "admin"
    t.json "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "asset_prices", "assets"
  add_foreign_key "asset_prices", "currencies"
  add_foreign_key "asset_prices", "partner_resources"
  add_foreign_key "assets", "users"
  add_foreign_key "automatic_rebalance_options", "investment_portfolios"
  add_foreign_key "currency_parities", "currencies", column: "currency_from_id"
  add_foreign_key "currency_parities", "currencies", column: "currency_to_id"
  add_foreign_key "currency_parity_exchange_rates", "currency_parities"
  add_foreign_key "currency_parity_exchange_rates", "partner_resources"
  add_foreign_key "customer_support_item_messages", "customer_support_items"
  add_foreign_key "customer_support_item_messages", "users"
  add_foreign_key "customer_support_items", "users"
  add_foreign_key "investment_portfolio_assets", "assets"
  add_foreign_key "investment_portfolio_assets", "investment_portfolios"
  add_foreign_key "investment_portfolios", "users"
  add_foreign_key "partner_resources", "partners"
  add_foreign_key "rebalance_orders", "investment_portfolios"
  add_foreign_key "rebalance_orders", "users"
  add_foreign_key "rebalances", "rebalance_orders"
end
