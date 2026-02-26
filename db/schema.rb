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

ActiveRecord::Schema[8.1].define(version: 9) do
  create_table "animals", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "species", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_animals_on_user_id_and_name"
    t.index ["user_id"], name: "index_animals_on_user_id"
  end

  create_table "consumable_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "default_unit", default: "g", null: false
    t.integer "feeding_days_left"
    t.boolean "feeding_needs_order"
    t.string "name", null: false
    t.json "nutrition"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["category"], name: "index_consumable_items_on_category"
    t.index ["name"], name: "index_consumable_items_on_name"
    t.index ["user_id"], name: "index_consumable_items_on_user_id"
  end

  create_table "consumption_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "care_subject_id", null: false
    t.string "care_subject_type", null: false
    t.bigint "consumable_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "occurred_at", null: false
    t.decimal "quantity", precision: 12, scale: 4, null: false
    t.string "source"
    t.string "unit", default: "g", null: false
    t.datetime "updated_at", null: false
    t.index ["care_subject_type", "care_subject_id", "occurred_at"], name: "index_consumption_events_on_care_subject_and_occurred_at"
    t.index ["care_subject_type", "care_subject_id"], name: "index_consumption_events_on_care_subject"
    t.index ["consumable_item_id"], name: "index_consumption_events_on_consumable_item_id"
  end

  create_table "consumption_rules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.decimal "amount", precision: 12, scale: 4, null: false
    t.bigint "care_subject_id", null: false
    t.string "care_subject_type", null: false
    t.bigint "consumable_item_id", null: false
    t.datetime "created_at", null: false
    t.date "ends_on"
    t.string "kind"
    t.string "period", null: false
    t.date "starts_on"
    t.string "unit", default: "g", null: false
    t.datetime "updated_at", null: false
    t.index ["care_subject_type", "care_subject_id", "consumable_item_id"], name: "index_consumption_rules_on_subject_and_item"
    t.index ["care_subject_type", "care_subject_id"], name: "index_consumption_rules_on_care_subject"
    t.index ["consumable_item_id"], name: "index_consumption_rules_on_consumable_item_id"
  end

  create_table "ideal_nutrient_profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "kcal_per_day_target", precision: 10, scale: 2
    t.json "nutrients_target"
    t.bigint "profilable_id", null: false
    t.string "profilable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["profilable_type", "profilable_id"], name: "index_ideal_nutrient_profiles_on_profilable"
  end

  create_table "plants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "blooming_end_date"
    t.date "blooming_start_date"
    t.datetime "created_at", null: false
    t.boolean "fertilized_ok"
    t.string "fertilizer_amount"
    t.string "fertilizer_type"
    t.integer "fertilizing_interval_days"
    t.datetime "last_checked_at"
    t.string "light"
    t.string "location"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "watered_ok"
    t.string "watering_amount"
    t.integer "watering_interval_days"
    t.index ["user_id", "name"], name: "index_plants_on_user_id_and_name"
    t.index ["user_id"], name: "index_plants_on_user_id"
  end

  create_table "restock_alerts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "acknowledged", default: false, null: false
    t.bigint "care_subject_id", null: false
    t.string "care_subject_type", null: false
    t.bigint "consumable_item_id", null: false
    t.datetime "created_at", null: false
    t.decimal "days_left", precision: 8, scale: 2
    t.date "restock_by"
    t.datetime "updated_at", null: false
    t.index ["acknowledged"], name: "index_restock_alerts_on_acknowledged"
    t.index ["care_subject_type", "care_subject_id"], name: "index_restock_alerts_on_care_subject"
    t.index ["consumable_item_id"], name: "index_restock_alerts_on_consumable_item_id"
  end

  create_table "stock_lots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "consumable_item_id", null: false
    t.datetime "created_at", null: false
    t.date "expires_on"
    t.string "notes"
    t.date "purchased_on", null: false
    t.decimal "quantity", precision: 12, scale: 4, null: false
    t.string "unit", default: "g", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["consumable_item_id", "purchased_on"], name: "index_stock_lots_on_consumable_item_id_and_purchased_on"
    t.index ["consumable_item_id"], name: "index_stock_lots_on_consumable_item_id"
    t.index ["user_id"], name: "index_stock_lots_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "animals", "users"
  add_foreign_key "consumable_items", "users"
  add_foreign_key "consumption_events", "consumable_items"
  add_foreign_key "consumption_rules", "consumable_items"
  add_foreign_key "plants", "users"
  add_foreign_key "restock_alerts", "consumable_items"
  add_foreign_key "stock_lots", "consumable_items"
  add_foreign_key "stock_lots", "users"
end
