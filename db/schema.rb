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

ActiveRecord::Schema.define(version: 20160531090402) do

  create_table "advert_prices", force: :cascade do |t|
    t.integer  "advert_id",                                        null: false
    t.integer  "level_id",                                         null: false
    t.decimal  "price",      precision: 8, scale: 2, default: 0.0, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "adverts", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.integer  "topic_id"
    t.integer  "topic_group_id", null: false
    t.string   "other_name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "bigbluebutton_meetings", force: :cascade do |t|
    t.integer  "server_id"
    t.integer  "room_id"
    t.string   "meetingid"
    t.string   "name"
    t.datetime "start_time"
    t.boolean  "running",      default: false
    t.boolean  "recorded",     default: false
    t.integer  "creator_id"
    t.string   "creator_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bigbluebutton_meetings", ["meetingid", "start_time"], name: "index_bigbluebutton_meetings_on_meetingid_and_start_time", unique: true

  create_table "bigbluebutton_metadata", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_playback_formats", force: :cascade do |t|
    t.integer  "recording_id"
    t.integer  "playback_type_id"
    t.string   "url"
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_playback_types", force: :cascade do |t|
    t.string   "identifier"
    t.boolean  "visible",    default: false
    t.boolean  "default",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_recordings", force: :cascade do |t|
    t.integer  "server_id"
    t.integer  "room_id"
    t.integer  "meeting_id"
    t.string   "recordid"
    t.string   "meetingid"
    t.string   "name"
    t.boolean  "published",             default: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "available",             default: true
    t.string   "description"
    t.integer  "size",        limit: 8, default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bigbluebutton_recordings", ["recordid"], name: "index_bigbluebutton_recordings_on_recordid", unique: true
  add_index "bigbluebutton_recordings", ["room_id"], name: "index_bigbluebutton_recordings_on_room_id"

  create_table "bigbluebutton_room_options", force: :cascade do |t|
    t.integer  "room_id"
    t.string   "default_layout"
    t.boolean  "presenter_share_only"
    t.boolean  "auto_start_video"
    t.boolean  "auto_start_audio"
    t.string   "background"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bigbluebutton_room_options", ["room_id"], name: "index_bigbluebutton_room_options_on_room_id"

  create_table "bigbluebutton_rooms", force: :cascade do |t|
    t.integer  "server_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "meetingid"
    t.string   "name"
    t.string   "attendee_key"
    t.string   "moderator_key"
    t.string   "welcome_msg"
    t.string   "logout_url"
    t.string   "voice_bridge"
    t.string   "dial_number"
    t.integer  "max_participants"
    t.boolean  "private",                                   default: false
    t.boolean  "external",                                  default: false
    t.string   "param"
    t.boolean  "record_meeting",                            default: false
    t.integer  "duration",                                  default: 0
    t.string   "attendee_api_password"
    t.string   "moderator_api_password"
    t.decimal  "create_time",                precision: 14
    t.string   "moderator_only_message"
    t.boolean  "auto_start_recording",                      default: false
    t.boolean  "allow_start_stop_recording",                default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lesson_id"
  end

  add_index "bigbluebutton_rooms", ["meetingid"], name: "index_bigbluebutton_rooms_on_meetingid", unique: true
  add_index "bigbluebutton_rooms", ["server_id"], name: "index_bigbluebutton_rooms_on_server_id"

  create_table "bigbluebutton_server_configs", force: :cascade do |t|
    t.integer  "server_id"
    t.text     "available_layouts"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_servers", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.string   "salt"
    t.string   "version"
    t.string   "param"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "sender_id",    null: false
    t.integer  "subject_id",   null: false
    t.text     "comment_text", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "degrees", force: :cascade do |t|
    t.string   "title",           null: false
    t.string   "institution",     null: false
    t.integer  "completion_year"
    t.integer  "user_id",         null: false
    t.integer  "level_id",        null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "degrees", ["level_id"], name: "index_degrees_on_level_id"
  add_index "degrees", ["user_id"], name: "index_degrees_on_user_id"

  create_table "galleries", force: :cascade do |t|
    t.integer  "cover"
    t.string   "token"
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lessons", force: :cascade do |t|
    t.integer  "student_id",                                             null: false
    t.integer  "teacher_id",                                             null: false
    t.integer  "status",                                 default: 0,     null: false
    t.datetime "time_start",                                             null: false
    t.datetime "time_end",                                               null: false
    t.integer  "topic_id"
    t.integer  "topic_group_id",                                         null: false
    t.integer  "level_id",                                               null: false
    t.decimal  "price",          precision: 8, scale: 2,                 null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "freeLesson",                             default: false
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

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.integer "unsubscriber_id"
    t.string  "unsubscriber_type"
    t.integer "conversation_id"
  end

  add_index "mailboxer_conversation_opt_outs", ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id"
  add_index "mailboxer_conversation_opt_outs", ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type"

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.string   "notification_code"
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "attachment"
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id"
  add_index "mailboxer_notifications", ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type"
  add_index "mailboxer_notifications", ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type"
  add_index "mailboxer_notifications", ["type"], name: "index_mailboxer_notifications_on_type"

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id"
  add_index "mailboxer_receipts", ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type"

  create_table "payments", force: :cascade do |t|
    t.integer  "status",                                    default: 0,                     null: false
    t.integer  "payment_type",                              default: 0,                     null: false
    t.datetime "transfert_date",                            default: '2016-05-31 15:33:58', null: false
    t.decimal  "price",             precision: 8, scale: 2,                                 null: false
    t.integer  "lesson_id",                                                                 null: false
    t.integer  "mangopay_payin_id"
    t.datetime "execution_date"
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
  end

  create_table "pictures", force: :cascade do |t|
    t.string   "description"
    t.string   "image"
    t.integer  "gallery_id",         null: false
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
    t.integer  "user_id",                             null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "read_marks", force: :cascade do |t|
    t.integer  "readable_id"
    t.string   "readable_type", null: false
    t.integer  "reader_id"
    t.string   "reader_type",   null: false
    t.datetime "timestamp"
  end

  add_index "read_marks", ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index"

  create_table "reviews", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "subject_id"
    t.text     "review_text"
    t.integer  "note"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "topic_groups", force: :cascade do |t|
    t.string   "title",          null: false
    t.string   "level_code",     null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "topic_group_id"
  end

  create_table "topics", force: :cascade do |t|
    t.string   "title",          null: false
    t.integer  "topic_group_id", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "topics_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                  default: "",            null: false
    t.string   "firstname",              default: "",            null: false
    t.string   "lastname",               default: "",            null: false
    t.date     "birthdate",              default: '2016-01-01',  null: false
    t.text     "description",            default: "",            null: false
    t.string   "gender",                 default: "Not telling", null: false
    t.string   "phonenumber",            default: "",            null: false
    t.string   "type",                   default: "Student",     null: false
    t.integer  "level_id",               default: 1
    t.boolean  "first_lesson_free",      default: false
    t.boolean  "accepts_post_payments",  default: false
    t.string   "occupation",             default: "student"
    t.boolean  "postulance_accepted",    default: false,         null: false
    t.string   "teacher_status",         default: "Actif"
    t.string   "email",                  default: "",            null: false
    t.string   "encrypted_password",     default: "",            null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,             null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,             null: false
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
    t.datetime "last_seen"
    t.string   "time_zone",              default: "UTC"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

end
