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

ActiveRecord::Schema[8.0].define(version: 2026_02_03_071109) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "stations", force: :cascade do |t|
    t.string "name", null: false
    t.string "operator_name", null: false
    t.decimal "latitude", precision: 10, scale: 7, null: false
    t.decimal "longitude", precision: 10, scale: 7, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["operator_name", "name"], name: "index_stations_on_operator_name_and_name", unique: true
  end

  create_table "toilets", force: :cascade do |t|
    t.bigint "station_id", null: false
    t.string "name", null: false
    t.decimal "latitude", precision: 10, scale: 7, null: false
    t.decimal "longitude", precision: 10, scale: 7, null: false
    t.text "location_note"
    t.boolean "is_wheelchair_accessible", default: false, null: false
    t.boolean "is_ostomate_accessible", default: false, null: false
    t.boolean "is_baby_friendly", default: false, null: false
    t.boolean "is_gender_separated", default: false, null: false
    t.boolean "is_multipurpose", default: false, null: false
    t.integer "style_type", default: 2, null: false
    t.string "place_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_washlet"
    t.index ["station_id"], name: "index_toilets_on_station_id"
  end

  add_foreign_key "toilets", "stations"
end
