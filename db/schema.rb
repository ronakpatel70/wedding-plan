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

ActiveRecord::Schema.define(version: 20161103121256) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "hstore"

  create_table "add_ons", force: :cascade do |t|
    t.integer  "booth_id",                null: false
    t.text     "type",                    null: false
    t.integer  "quantity",    default: 1, null: false
    t.text     "value"
    t.text     "description"
    t.integer  "price",       default: 0, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["booth_id"], name: "index_add_ons_on_booth_id", using: :btree
    t.index ["type"], name: "index_add_ons_on_type", using: :btree
    t.index ["value"], name: "index_add_ons_on_value", using: :btree
  end

  create_table "addresses", force: :cascade do |t|
    t.text     "name"
    t.text     "street",                              null: false
    t.text     "city",                                null: false
    t.string   "state",      limit: 2, default: "CA", null: false
    t.string   "zip",        limit: 5,                null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "articles", force: :cascade do |t|
    t.integer  "page",       null: false
    t.string   "title",      null: false
    t.integer  "order",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "content"
    t.index ["order", "page"], name: "index_articles_on_order_and_page", unique: true, using: :btree
  end

  create_table "booths", force: :cascade do |t|
    t.integer  "show_id",                            null: false
    t.integer  "vendor_id",                          null: false
    t.integer  "status",             default: 0,     null: false
    t.string   "size"
    t.text     "requests"
    t.integer  "coordinate_id"
    t.integer  "sign_id"
    t.integer  "total",              default: 0,     null: false
    t.integer  "balance",            default: 0,     null: false
    t.integer  "payment_method",     default: 0,     null: false
    t.integer  "payment_schedule",   default: 0,     null: false
    t.integer  "card_id"
    t.boolean  "visible",            default: true,  null: false
    t.boolean  "leads_access",       default: true,  null: false
    t.boolean  "flagged",            default: false, null: false
    t.boolean  "received_marketing", default: false, null: false
    t.integer  "free_pass_limit",    default: 25,    null: false
    t.datetime "checked_in_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "industries",         default: [],    null: false, array: true
    t.index ["card_id"], name: "index_booths_on_card_id", using: :btree
    t.index ["show_id", "sign_id"], name: "index_booths_on_show_id_and_sign_id", unique: true, using: :btree
    t.index ["show_id"], name: "index_booths_on_show_id", using: :btree
    t.index ["vendor_id"], name: "index_booths_on_vendor_id", using: :btree
  end

  create_table "cards", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "stripe_card_id",                       null: false
    t.string   "brand",                                null: false
    t.string   "funding"
    t.date     "expiry",                               null: false
    t.string   "last4",          limit: 4,             null: false
    t.string   "name",                                 null: false
    t.integer  "status",                   default: 0, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["owner_type", "owner_id"], name: "index_cards_on_owner_type_and_owner_id", using: :btree
  end

  create_table "coordinates", force: :cascade do |t|
    t.decimal  "x",                          null: false
    t.decimal  "y",                          null: false
    t.decimal  "a",          default: "0.0", null: false
    t.string   "section"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "events", force: :cascade do |t|
    t.date     "date"
    t.integer  "rewards_points",    default: 1, null: false
    t.datetime "joined_rewards_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["date"], name: "index_events_on_date", using: :btree
  end

  create_table "events_users", id: false, force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id",  null: false
  end

  create_table "fees", force: :cascade do |t|
    t.integer  "booth_id",    null: false
    t.integer  "amount",      null: false
    t.string   "description", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["booth_id"], name: "index_fees_on_booth_id", using: :btree
  end

  create_table "job_applications", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.integer  "show_id",                     null: false
    t.integer  "status",          default: 0, null: false
    t.text     "requests"
    t.string   "requested_start"
    t.string   "requested_end"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["show_id", "user_id"], name: "index_job_applications_on_show_id_and_user_id", unique: true, using: :btree
    t.index ["show_id"], name: "index_job_applications_on_show_id", using: :btree
    t.index ["user_id"], name: "index_job_applications_on_user_id", using: :btree
  end

  create_table "locations", force: :cascade do |t|
    t.text     "handle",     null: false
    t.text     "name",       null: false
    t.integer  "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_locations_on_address_id", using: :btree
    t.index ["handle"], name: "index_locations_on_handle", unique: true, using: :btree
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id",                  null: false
    t.string   "sender_type",                null: false
    t.integer  "recipient_id",               null: false
    t.string   "recipient_type",             null: false
    t.string   "from",                       null: false
    t.string   "to",                         null: false
    t.datetime "read_at"
    t.string   "subject"
    t.text     "body",                       null: false
    t.integer  "type",           default: 0, null: false
    t.string   "template"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["recipient_type", "recipient_id"], name: "index_messages_on_recipient_type_and_recipient_id", using: :btree
    t.index ["sender_type", "sender_id"], name: "index_messages_on_sender_type_and_sender_id", using: :btree
  end

  create_table "offers", force: :cascade do |t|
    t.integer  "vendor_id",                  null: false
    t.integer  "tier",       default: 1,     null: false
    t.integer  "value",      default: 1,     null: false
    t.integer  "type",       default: 0,     null: false
    t.string   "name",                       null: false
    t.text     "rules"
    t.boolean  "combo",      default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["tier", "vendor_id"], name: "index_offers_on_tier_and_vendor_id", unique: true, using: :btree
    t.index ["vendor_id"], name: "index_offers_on_vendor_id", using: :btree
  end

  create_table "packages", force: :cascade do |t|
    t.integer  "show_id",                null: false
    t.integer  "ribbon"
    t.integer  "type",       default: 0, null: false
    t.string   "name"
    t.text     "rules"
    t.integer  "winner_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["show_id", "ribbon"], name: "index_packages_on_show_id_and_ribbon", unique: true, using: :btree
    t.index ["show_id"], name: "index_packages_on_show_id", using: :btree
    t.index ["winner_id"], name: "index_packages_on_winner_id", using: :btree
  end

  create_table "packages_prizes", id: false, force: :cascade do |t|
    t.integer "package_id", null: false
    t.integer "prize_id",   null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "amount",                       null: false
    t.integer  "refund_amount",    default: 0, null: false
    t.string   "description",                  null: false
    t.integer  "method",           default: 0, null: false
    t.integer  "status",           default: 0, null: false
    t.string   "reason"
    t.string   "stripe_charge_id"
    t.integer  "card_id"
    t.integer  "payable_id"
    t.string   "payable_type"
    t.integer  "payer_id",                     null: false
    t.string   "payer_type",                   null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.date     "scheduled_for"
    t.datetime "captured_at"
    t.index ["card_id"], name: "index_payments_on_card_id", using: :btree
    t.index ["payable_type", "payable_id"], name: "index_payments_on_payable_type_and_payable_id", using: :btree
    t.index ["payer_type", "payer_id"], name: "index_payments_on_payer_type_and_payer_id", using: :btree
  end

  create_table "points", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "vendor_id",              null: false
    t.integer  "status",     default: 0, null: false
    t.string   "reason"
    t.date     "date",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "quantity",   default: 1, null: false
    t.index ["event_id", "vendor_id"], name: "index_points_on_event_id_and_vendor_id", unique: true, using: :btree
    t.index ["event_id"], name: "index_points_on_event_id", using: :btree
    t.index ["vendor_id"], name: "index_points_on_vendor_id", using: :btree
  end

  create_table "positions", force: :cascade do |t|
    t.string   "name",                                  null: false
    t.text     "description"
    t.string   "short_description",                     null: false
    t.integer  "quantity",          default: 1,         null: false
    t.boolean  "active",            default: true,      null: false
    t.string   "default_start",     default: "10:30am", null: false
    t.string   "default_end",       default: "5:00pm",  null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "prizes", force: :cascade do |t|
    t.integer  "show_id",                       null: false
    t.integer  "vendor_id",                     null: false
    t.string   "name",                          null: false
    t.integer  "quantity",      default: 1,     null: false
    t.integer  "value",         default: 1000,  null: false
    t.text     "rules"
    t.integer  "type",          default: 0,     null: false
    t.integer  "status",        default: 0,     null: false
    t.integer  "coordinate_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "is_manned",     default: false, null: false
    t.index ["show_id"], name: "index_prizes_on_show_id", using: :btree
    t.index ["vendor_id"], name: "index_prizes_on_vendor_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "type",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type", "user_id"], name: "index_roles_on_type_and_user_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_roles_on_user_id", using: :btree
  end

  create_table "shifts", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.integer  "position_id",             null: false
    t.integer  "show_id",                 null: false
    t.datetime "start_time",              null: false
    t.datetime "end_time",                null: false
    t.integer  "status",      default: 0, null: false
    t.text     "notes"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "in_time"
    t.datetime "out_time"
    t.index ["position_id"], name: "index_shifts_on_position_id", using: :btree
    t.index ["show_id"], name: "index_shifts_on_show_id", using: :btree
    t.index ["user_id"], name: "index_shifts_on_user_id", using: :btree
  end

  create_table "shows", force: :cascade do |t|
    t.integer  "location_id",                        null: false
    t.datetime "start",                              null: false
    t.datetime "end",                                null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "early_bird_price",    default: 1200, null: false
    t.integer  "online_price",        default: 1200, null: false
    t.integer  "door_price",          default: 1500, null: false
    t.integer  "wine_tasting_price",  default: 500,  null: false
    t.date     "early_bird_end_date"
    t.integer  "prize_ribbons",       default: 600,  null: false
    t.index ["location_id"], name: "index_shows_on_location_id", using: :btree
  end

  create_table "shows_users", id: false, force: :cascade do |t|
    t.integer "show_id", null: false
    t.integer "user_id", null: false
  end

  create_table "signs", force: :cascade do |t|
    t.string   "front",                         null: false
    t.string   "back"
    t.boolean  "missing",       default: false, null: false
    t.boolean  "informational", default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "signs_vendors", id: false, force: :cascade do |t|
    t.integer "sign_id",   null: false
    t.integer "vendor_id", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string   "stripe_subscription_id",             null: false
    t.string   "stripe_customer_id",                 null: false
    t.integer  "vendor_id",                          null: false
    t.integer  "status",                 default: 0, null: false
    t.string   "plan",                               null: false
    t.string   "coupon"
    t.datetime "current_period_end"
    t.datetime "canceled_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.datetime "trial_end"
    t.index ["vendor_id"], name: "index_subscriptions_on_vendor_id", using: :btree
  end

  create_table "testimonials", force: :cascade do |t|
    t.integer  "vendor_id",  null: false
    t.text     "quote",      null: false
    t.string   "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_id"], name: "index_testimonials_on_vendor_id", using: :btree
  end

  create_table "texts", force: :cascade do |t|
    t.string   "sender_type"
    t.integer  "sender_id"
    t.string   "recipient_type"
    t.integer  "recipient_id"
    t.text     "message",                    null: false
    t.integer  "group"
    t.integer  "status",         default: 0, null: false
    t.text     "sender_tel"
    t.text     "recipient_tel"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["recipient_type", "recipient_id"], name: "index_texts_on_recipient_type_and_recipient_id", using: :btree
    t.index ["sender_type", "sender_id"], name: "index_texts_on_sender_type_and_sender_id", using: :btree
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "show_id",                               null: false
    t.integer  "user_id",                               null: false
    t.integer  "quantity",   limit: 2,  default: 1,     null: false
    t.boolean  "free",                  default: false, null: false
    t.integer  "vendor_id"
    t.string   "url",        limit: 24
    t.boolean  "paid",                  default: true,  null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["show_id", "user_id"], name: "index_tickets_on_show_id_and_user_id", using: :btree
    t.index ["show_id", "vendor_id"], name: "index_tickets_on_show_id_and_vendor_id", using: :btree
    t.index ["show_id"], name: "index_tickets_on_show_id", using: :btree
    t.index ["url"], name: "index_tickets_on_url", unique: true, using: :btree
    t.index ["user_id"], name: "index_tickets_on_user_id", using: :btree
    t.index ["vendor_id"], name: "index_tickets_on_vendor_id", using: :btree
  end

  create_table "tokens", id: :text, force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.datetime "expires_at", null: false
    t.index ["user_id"], name: "index_tokens_on_user_id", using: :btree
  end

  create_table "transfers", force: :cascade do |t|
    t.integer  "amount",                          null: false
    t.string   "description",                     null: false
    t.integer  "status",              default: 0, null: false
    t.string   "failure_message"
    t.integer  "user_id",                         null: false
    t.string   "stripe_transfer_id",              null: false
    t.string   "stripe_recipient_id",             null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["user_id"], name: "index_transfers_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.citext   "email",                               null: false
    t.text     "password_digest"
    t.text     "first_name",                          null: false
    t.text     "last_name",                           null: false
    t.string   "phone"
    t.integer  "address_id"
    t.integer  "event_role",          default: 0,     null: false
    t.boolean  "receive_email",       default: true,  null: false
    t.boolean  "receive_sms",         default: false, null: false
    t.text     "stripe_customer_id"
    t.text     "stripe_recipient_id"
    t.integer  "default_card_id"
    t.integer  "failed_attempts",     default: 0,     null: false
    t.datetime "locked_at"
    t.datetime "password_updated_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true, using: :btree
    t.index ["stripe_recipient_id"], name: "index_users_on_stripe_recipient_id", unique: true, using: :btree
  end

  create_table "users_vendors", id: false, force: :cascade do |t|
    t.integer "user_id",   null: false
    t.integer "vendor_id", null: false
  end

  create_table "vendors", force: :cascade do |t|
    t.text     "name",                                       null: false
    t.text     "former_name"
    t.citext   "email",                                      null: false
    t.string   "phone",                                      null: false
    t.text     "contact",                                    null: false
    t.integer  "billing_address_id"
    t.integer  "storefront_address_id"
    t.integer  "industry",                   default: 22,    null: false
    t.text     "website"
    t.text     "facebook"
    t.text     "stripe_customer_id"
    t.integer  "default_card_id"
    t.integer  "rewards_status",             default: 0,     null: false
    t.text     "rewards_profile"
    t.string   "profile_image_file_name"
    t.string   "profile_image_content_type"
    t.integer  "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "grab_card_status",           default: 0,     null: false
    t.boolean  "has_slides",                 default: false, null: false
    t.hstore   "show_statuses",              default: {},    null: false
    t.string   "cell_phone"
    t.boolean  "allow_multi_points",         default: false, null: false
    t.string   "old_email"
    t.index ["former_name"], name: "index_vendors_on_former_name", using: :btree
    t.index ["name"], name: "index_vendors_on_name", unique: true, using: :btree
    t.index ["show_statuses"], name: "index_vendors_on_show_statuses", using: :gist
    t.index ["stripe_customer_id"], name: "index_vendors_on_stripe_customer_id", unique: true, using: :btree
  end

  add_foreign_key "add_ons", "booths"
  add_foreign_key "booths", "cards"
  add_foreign_key "booths", "coordinates"
  add_foreign_key "booths", "shows"
  add_foreign_key "booths", "signs"
  add_foreign_key "booths", "vendors"
  add_foreign_key "fees", "booths"
  add_foreign_key "job_applications", "shows"
  add_foreign_key "job_applications", "users"
  add_foreign_key "locations", "addresses"
  add_foreign_key "offers", "vendors"
  add_foreign_key "packages", "shows"
  add_foreign_key "packages", "users", column: "winner_id"
  add_foreign_key "payments", "cards"
  add_foreign_key "points", "events"
  add_foreign_key "points", "vendors"
  add_foreign_key "prizes", "coordinates"
  add_foreign_key "prizes", "shows"
  add_foreign_key "prizes", "vendors"
  add_foreign_key "roles", "users"
  add_foreign_key "shifts", "positions"
  add_foreign_key "shifts", "shows"
  add_foreign_key "shifts", "users"
  add_foreign_key "shows", "locations"
  add_foreign_key "subscriptions", "vendors"
  add_foreign_key "testimonials", "vendors"
  add_foreign_key "tickets", "shows"
  add_foreign_key "tickets", "users"
  add_foreign_key "tickets", "vendors"
  add_foreign_key "tokens", "users"
  add_foreign_key "transfers", "users"
  add_foreign_key "users", "addresses"
  add_foreign_key "users", "cards", column: "default_card_id"
  add_foreign_key "vendors", "addresses", column: "billing_address_id"
  add_foreign_key "vendors", "addresses", column: "storefront_address_id"
  add_foreign_key "vendors", "cards", column: "default_card_id"
end
