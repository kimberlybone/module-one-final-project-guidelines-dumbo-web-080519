# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190822135819) do

  create_table "appointments", force: :cascade do |t|
    t.string  "date"
    t.string  "time"
    t.integer "doctor_id"
    t.integer "patient_id"
    t.string  "reason"
  end

  create_table "doctors", force: :cascade do |t|
    t.string "name"
    t.string "specialty"
  end

  create_table "patients", force: :cascade do |t|
    t.string "name"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "rating"
    t.string  "content"
    t.integer "doctor_id"
    t.integer "patient_id"
  end

end
