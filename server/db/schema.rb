# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160414045846) do

  create_table "lien_subsequent_batches", id: false, force: :cascade do |t|
    t.integer "lien_id",             null: false
    t.integer "subsequent_batch_id", null: false
  end

  create_table "liens", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "township_id"
    t.date     "sale_date"
    t.string   "county"
    t.string   "year"
    t.string   "block_lot"
    t.string   "block"
    t.string   "lot"
    t.string   "qualifier"
    t.string   "adv_number"
    t.string   "lien_type"
    t.string   "list_item"
    t.string   "longitude"
    t.string   "latitude"
    t.integer  "assessed_value"
    t.integer  "tax_amount"
    t.string   "status"
    t.integer  "cert_fv"
    t.decimal  "winning_bid",        precision: 4
    t.integer  "total_paid"
    t.integer  "total_cash_out"
    t.integer  "total_interest_due"
    t.integer  "search_fee"
    t.integer  "yep_interest"
    t.string   "cert_number"
    t.string   "address"
    t.integer  "premium"
    t.integer  "recording_fee"
    t.date     "recording_date"
    t.integer  "flat_rate"
    t.integer  "cert_int"
    t.integer  "yep_2013"
    t.string   "picture"
    t.date     "redemption_date"
    t.integer  "redemption_amount"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "redeem_in_10"
  end

  add_index "liens", ["township_id"], name: "index_liens_on_township_id"

  create_table "liens_llcs", id: false, force: :cascade do |t|
    t.integer "lien_id", null: false
    t.integer "llc_id",  null: false
  end

  create_table "liens_mua_accounts", id: false, force: :cascade do |t|
    t.integer "lien_id",        null: false
    t.integer "mua_account_id", null: false
  end

  create_table "liens_notes", id: false, force: :cascade do |t|
    t.integer "lien_id", null: false
    t.integer "note_id", null: false
  end

  create_table "liens_owners", id: false, force: :cascade do |t|
    t.integer "lien_id",  null: false
    t.integer "owner_id", null: false
  end

  create_table "llcs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "mua_accounts", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "account_number"
    t.integer  "lien_id"
  end

  add_index "mua_accounts", ["lien_id"], name: "index_mua_accounts_on_lien_id"

  create_table "notes", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "comment"
    t.integer  "lien_id"
    t.integer  "profile_id"
    t.integer  "external_id"
    t.string   "note_type"
  end

  add_index "notes", ["lien_id"], name: "index_notes_on_lien_id"
  add_index "notes", ["profile_id"], name: "index_notes_on_profile_id"

  create_table "notes_receipts", id: false, force: :cascade do |t|
    t.integer "receipt_id", null: false
    t.integer "note_id",    null: false
  end

  create_table "notes_subsequents", id: false, force: :cascade do |t|
    t.integer "subsequent_id", null: false
    t.integer "note_id",       null: false
  end

  create_table "owners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "cid"
    t.date    "birthday"
    t.string  "sex"
    t.string  "tel"
    t.string  "address"
    t.string  "tagline"
    t.text    "introduction"
    t.string  "name"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id"

  create_table "receipts", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "lien_id"
    t.date     "check_date"
    t.date     "deposit_date"
    t.date     "redeem_date"
    t.string   "check_number"
    t.string   "receipt_type"
    t.integer  "check_amount"
    t.boolean  "void"
    t.string   "account_type"
    t.integer  "subsequent_id"
    t.integer  "misc_principal"
  end

  add_index "receipts", ["lien_id"], name: "index_receipts_on_lien_id"
  add_index "receipts", ["subsequent_id"], name: "index_receipts_on_subsequent_id"

  create_table "subsequent_batches", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.date     "sub_date"
    t.boolean  "void"
    t.integer  "township_id"
  end

  add_index "subsequent_batches", ["township_id"], name: "index_subsequent_batches_on_township_id"

  create_table "subsequents", force: :cascade do |t|
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "lien_id"
    t.integer  "subsequent_id"
    t.date     "sub_date"
    t.string   "sub_type"
    t.integer  "amount"
    t.boolean  "void"
    t.integer  "subsequent_batch_id"
  end

  add_index "subsequents", ["lien_id"], name: "index_subsequents_on_lien_id"
  add_index "subsequents", ["subsequent_batch_id"], name: "index_subsequents_on_subsequent_batch_id"
  add_index "subsequents", ["subsequent_id"], name: "index_subsequents_on_subsequent_id"

  create_table "townships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
