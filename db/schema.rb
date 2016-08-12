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

ActiveRecord::Schema.define(version: 20160812105254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "rebases", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "repo"
    t.string   "base"
    t.string   "head"
    t.string   "sha"
    t.boolean  "pushed",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["repo"], name: "index_rebases_on_repo", using: :btree
    t.index ["user_id"], name: "index_rebases_on_user_id", using: :btree
  end

  create_table "repos", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "ssh"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_repos_on_name", using: :btree
    t.index ["user_id"], name: "index_repos_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "username"
    t.string   "avatar"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "github_id"
  end

  add_foreign_key "rebases", "users"
  add_foreign_key "repos", "users"
end
