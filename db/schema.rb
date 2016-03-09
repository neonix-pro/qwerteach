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

ActiveRecord::Schema.define(version: 20160304100717) do


  create_table "advert_prices", force: :cascade do |t|
    t.integer  "advert_id"
    t.integer  "level_id"
    t.decimal  "price",      precision: 8, scale: 2
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "adverts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.string   "other_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "subject_id"
    t.text     "comment_text"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "conversations", ["recipient_id"], name: "index_conversations_on_recipient_id"
  add_index "conversations", ["sender_id"], name: "index_conversations_on_sender_id"

  create_table "degrees", force: :cascade do |t|
    t.string   "title"
    t.string   "institution"
    t.integer  "completion_year"
    t.integer  "user_id"
    t.integer  "level_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "degrees", ["level_id"], name: "index_degrees_on_level_id"
  add_index "degrees", ["user_id"], name: "index_degrees_on_user_id"

  create_table "galleries", force: :cascade do |t|
    t.integer  "cover"
    t.string   "token"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "levels", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",      default: 1, null: false
    t.string   "code",                   null: false
    t.string   "be",                     null: false
    t.string   "fr",                     null: false
    t.string   "ch",                     null: false
  end

  create_table "messages", force: :cascade do |t|
    t.text     "body"
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "messages", ["conversation_id"], name: "index_messages_on_conversation_id"
  add_index "messages", ["user_id"], name: "index_messages_on_user_id"

  create_table "pictures", force: :cascade do |t|
    t.string   "description"
    t.string   "image"
    t.integer  "gallery_id"
    t.string   "gallery_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "postulations", force: :cascade do |t|
    t.boolean  "interview_ok",        default: false
    t.boolean  "avatar_ok",           default: false
    t.boolean  "gen_informations_ok", default: false
    t.boolean  "advert_ok",           default: false
    t.integer  "user_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "topic_groups", force: :cascade do |t|
    t.string   "title"
    t.string   "level_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topics", force: :cascade do |t|
    t.string   "title"
    t.integer  "topic_group_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                  default: "",           null: false
    t.string   "firstname",              default: "",           null: false
    t.string   "lastname",               default: "",           null: false
    t.date     "birthdate",              default: '2016-01-01', null: false
    t.text     "description",            default: "",           null: false
    t.string   "gender",                 default: "",           null: false
    t.string   "phonenumber",            default: "",           null: false
    t.string   "type",                   default: "Student",    null: false
    t.integer  "level_id",               default: 1
    t.boolean  "first_lesson_free",      default: false
    t.string   "occupation",             default: "student"
    t.boolean  "postulance_accepted",    default: false,        null: false
    t.string   "teacher_status",         default: "Actif"
    t.string   "email",                  default: "",           null: false
    t.string   "encrypted_password",     default: "",           null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,            null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "mango_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

end
