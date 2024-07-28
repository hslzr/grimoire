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

ActiveRecord::Schema[7.1].define(version: 2024_07_28_232525) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "cards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "raw_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "sname", type: :text, as: "(raw_data ->> 'name'::text)", stored: true
    t.virtual "searchable", type: :tsvector, as: "(setweight(to_tsvector('english'::regconfig, COALESCE((raw_data ->> 'name'::text), ''::text)), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE((raw_data ->> 'printed_name'::text), ''::text)), 'B'::\"char\"))", stored: true
    t.index ["searchable"], name: "index_cards_on_searchable", using: :gin
  end

end
