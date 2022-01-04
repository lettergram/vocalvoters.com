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

ActiveRecord::Schema.define(version: 2022_01_04_054022) do

  create_table "emails", force: :cascade do |t|
    t.string "email_address"
    t.boolean "success", default: true
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.integer "letter_id", null: false
    t.string "payment", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["letter_id"], name: "index_emails_on_letter_id"
    t.index ["recipient_id"], name: "index_emails_on_recipient_id"
    t.index ["sender_id"], name: "index_emails_on_sender_id"
  end

  create_table "faxes", force: :cascade do |t|
    t.integer "number_fax"
    t.string "payment", null: false
    t.boolean "success", default: true
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.integer "letter_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["letter_id"], name: "index_faxes_on_letter_id"
    t.index ["recipient_id"], name: "index_faxes_on_recipient_id"
    t.index ["sender_id"], name: "index_faxes_on_sender_id"
  end

  create_table "letters", force: :cascade do |t|
    t.string "category"
    t.string "policy_or_law"
    t.string "tags"
    t.float "sentiment"
    t.text "body"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "target_level", default: "all"
    t.string "target_state", default: "all"
    t.integer "organization_id"
    t.boolean "editable", default: true
    t.integer "derived_from"
    t.index ["organization_id"], name: "index_letters_on_organization_id"
    t.index ["user_id"], name: "index_letters_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "approvals_required", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pay_charges", force: :cascade do |t|
    t.string "owner_type"
    t.integer "owner_id"
    t.string "processor", null: false
    t.string "processor_id", null: false
    t.integer "amount", null: false
    t.integer "amount_refunded"
    t.string "card_type"
    t.string "card_last4"
    t.string "card_exp_month"
    t.string "card_exp_year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json "data"
    t.string "currency"
    t.integer "application_fee_amount"
    t.integer "pay_subscription_id"
  end

  create_table "pay_subscriptions", force: :cascade do |t|
    t.string "owner_type"
    t.integer "owner_id"
    t.string "name", null: false
    t.string "processor", null: false
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "trial_ends_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status"
    t.json "data"
    t.decimal "application_fee_percent", precision: 8, scale: 2
  end

  create_table "posts", force: :cascade do |t|
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zipcode"
    t.string "payment", null: false
    t.boolean "priority", default: false
    t.boolean "success", default: true
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.integer "letter_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["letter_id"], name: "index_posts_on_letter_id"
    t.index ["recipient_id"], name: "index_posts_on_recipient_id"
    t.index ["sender_id"], name: "index_posts_on_sender_id"
  end

  create_table "recipients", force: :cascade do |t|
    t.string "name"
    t.string "position"
    t.string "level"
    t.string "district"
    t.string "state"
    t.integer "number_fax"
    t.integer "number_phone"
    t.string "email_address"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zipcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "contact_form"
    t.boolean "retired", default: false
  end

  create_table "senders", force: :cascade do |t|
    t.string "name"
    t.integer "zipcode"
    t.string "county"
    t.string "district"
    t.string "state"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.text "signature"
    t.index ["user_id"], name: "index_senders_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.boolean "org_admin"
    t.integer "organization_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "emails", "letters"
  add_foreign_key "emails", "recipients"
  add_foreign_key "emails", "senders"
  add_foreign_key "faxes", "letters"
  add_foreign_key "faxes", "recipients"
  add_foreign_key "faxes", "senders"
  add_foreign_key "letters", "organizations"
  add_foreign_key "letters", "users"
  add_foreign_key "posts", "letters"
  add_foreign_key "posts", "recipients"
  add_foreign_key "posts", "senders"
  add_foreign_key "senders", "users"
  add_foreign_key "users", "organizations"
end
