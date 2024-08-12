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

ActiveRecord::Schema[7.1].define(version: 2024_07_29_021528) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "card_flavor_names", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "lang"
    t.uuid "card_name_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "searchable", type: :tsvector, as: "to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)", stored: true
    t.index ["card_name_id"], name: "index_card_flavor_names_on_card_name_id"
    t.index ["name", "lang"], name: "index_card_flavor_names_on_name_and_lang", unique: true
  end

  create_table "card_names", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "lang"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "searchable", type: :tsvector, as: "to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)", stored: true
    t.index ["name", "lang"], name: "index_card_names_on_name_and_lang", unique: true
    t.index ["searchable"], name: "index_card_names_on_searchable", using: :gin
  end

  create_table "card_objects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "raw_data"
    t.uuid "card_name_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_name_id"], name: "index_card_objects_on_card_name_id"
  end

  create_table "card_printed_names", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "lang"
    t.uuid "card_name_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "searchable", type: :tsvector, as: "to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text)", stored: true
    t.index ["card_name_id"], name: "index_card_printed_names_on_card_name_id"
    t.index ["name", "lang"], name: "index_card_printed_names_on_name_and_lang", unique: true
  end

  add_foreign_key "card_flavor_names", "card_names"
  add_foreign_key "card_objects", "card_names"
  add_foreign_key "card_printed_names", "card_names"
end
