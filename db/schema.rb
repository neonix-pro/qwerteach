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

ActiveRecord::Schema.define(version: 20171113031305) do

  create_table "bigbluebutton_meetings", force: :cascade do |t|
    t.integer  "server_id",     limit: 4
    t.integer  "room_id",       limit: 4
    t.string   "meetingid",     limit: 255
    t.string   "name",          limit: 255
    t.datetime "start_time"
    t.boolean  "running",                                  default: false
    t.boolean  "recorded",                                 default: false
    t.integer  "creator_id",    limit: 4
    t.string   "creator_name",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ended"
    t.string   "server_url",    limit: 255
    t.string   "server_secret", limit: 255
    t.decimal  "create_time",               precision: 14
    t.integer  "finish_time",   limit: 8
  end

  add_index "bigbluebutton_meetings", ["meetingid", "create_time"], name: "index_bigbluebutton_meetings_on_meetingid_and_create_time", unique: true, using: :btree

  create_table "bigbluebutton_meetings_users", force: :cascade do |t|
    t.integer "bbb_meeting_id", limit: 4
    t.integer "user_id",        limit: 4
  end

  create_table "bigbluebutton_metadata", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4
    t.string   "owner_type", limit: 255
    t.string   "name",       limit: 255
    t.text     "content",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_playback_formats", force: :cascade do |t|
    t.integer  "recording_id",     limit: 4
    t.integer  "playback_type_id", limit: 4
    t.string   "url",              limit: 255
    t.integer  "length",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_playback_types", force: :cascade do |t|
    t.string   "identifier", limit: 255
    t.boolean  "visible",                default: false
    t.boolean  "default",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_recordings", force: :cascade do |t|
    t.integer  "server_id",   limit: 4
    t.integer  "room_id",     limit: 4
    t.integer  "meeting_id",  limit: 4
    t.string   "recordid",    limit: 255
    t.string   "meetingid",   limit: 255
    t.string   "name",        limit: 255
    t.boolean  "published",               default: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "available",               default: true
    t.string   "description", limit: 255
    t.integer  "size",        limit: 8,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bigbluebutton_recordings", ["recordid"], name: "index_bigbluebutton_recordings_on_recordid", unique: true, using: :btree
  add_index "bigbluebutton_recordings", ["room_id"], name: "index_bigbluebutton_recordings_on_room_id", using: :btree

  create_table "bigbluebutton_room_options", force: :cascade do |t|
    t.integer  "room_id",              limit: 4
    t.string   "default_layout",       limit: 255
    t.boolean  "presenter_share_only"
    t.boolean  "auto_start_video"
    t.boolean  "auto_start_audio"
    t.string   "background",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bigbluebutton_room_options", ["room_id"], name: "index_bigbluebutton_room_options_on_room_id", using: :btree

  create_table "bigbluebutton_rooms", force: :cascade do |t|
    t.integer  "server_id",                  limit: 4
    t.integer  "owner_id",                   limit: 4
    t.string   "owner_type",                 limit: 255
    t.string   "meetingid",                  limit: 255
    t.string   "name",                       limit: 255
    t.string   "attendee_key",               limit: 255
    t.string   "moderator_key",              limit: 255
    t.string   "welcome_msg",                limit: 255
    t.string   "logout_url",                 limit: 255
    t.string   "voice_bridge",               limit: 255
    t.string   "dial_number",                limit: 255
    t.integer  "max_participants",           limit: 4
    t.boolean  "private",                                               default: false
    t.boolean  "external",                                              default: false
    t.string   "param",                      limit: 255
    t.boolean  "record_meeting",                                        default: false
    t.integer  "duration",                   limit: 4,                  default: 0
    t.string   "attendee_api_password",      limit: 255
    t.string   "moderator_api_password",     limit: 255
    t.decimal  "create_time",                            precision: 14
    t.string   "moderator_only_message",     limit: 255
    t.boolean  "auto_start_recording",                                  default: false
    t.boolean  "allow_start_stop_recording",                            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lesson_id",                  limit: 4
    t.integer  "masterclass_id",             limit: 4
  end

  add_index "bigbluebutton_rooms", ["meetingid"], name: "index_bigbluebutton_rooms_on_meetingid", unique: true, using: :btree
  add_index "bigbluebutton_rooms", ["server_id"], name: "index_bigbluebutton_rooms_on_server_id", using: :btree

  create_table "bigbluebutton_server_configs", force: :cascade do |t|
    t.integer  "server_id",         limit: 4
    t.text     "available_layouts", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bigbluebutton_servers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "url",        limit: 255
    t.string   "secret",     limit: 255
    t.string   "version",    limit: 255
    t.string   "param",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.string   "title",            limit: 50,    default: ""
    t.text     "comment",          limit: 65535
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.integer  "user_id",          limit: 4
    t.string   "role",             limit: 255,   default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "degrees", force: :cascade do |t|
    t.string   "title",           limit: 255, null: false
    t.string   "institution",     limit: 255, null: false
    t.integer  "completion_year", limit: 4
    t.integer  "user_id",         limit: 4,   null: false
    t.integer  "level_id",        limit: 4,   null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "adress",          limit: 255
    t.integer  "postalCode",      limit: 4
    t.string   "city",            limit: 255
    t.string   "country",         limit: 255
  end

  add_index "degrees", ["level_id"], name: "index_degrees_on_level_id", using: :btree
  add_index "degrees", ["user_id"], name: "index_degrees_on_user_id", using: :btree

  create_table "disputes", force: :cascade do |t|
    t.integer  "status",     limit: 4, default: 0
    t.integer  "user_id",    limit: 4
    t.integer  "lesson_id",  limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "drafts", force: :cascade do |t|
    t.string   "target_type", limit: 255,   null: false
    t.integer  "user_id",     limit: 4
    t.integer  "parent_id",   limit: 4
    t.string   "parent_type", limit: 255
    t.binary   "data",        limit: 65535, null: false
    t.datetime "updated_at",                null: false
  end

  add_index "drafts", ["parent_type", "parent_id"], name: "index_drafts_on_parent_type_and_parent_id", using: :btree
  add_index "drafts", ["user_id", "target_type"], name: "index_drafts_on_user_id_and_target_type", using: :btree

  create_table "galleries", force: :cascade do |t|
    t.integer  "cover",      limit: 4
    t.string   "token",      limit: 255
    t.integer  "user_id",    limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interests", force: :cascade do |t|
    t.integer  "student_id", limit: 4, null: false
    t.integer  "topic_id",   limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.integer  "student_id",     limit: 4,                                             null: false
    t.integer  "teacher_id",     limit: 4,                                             null: false
    t.integer  "status",         limit: 4,                             default: 0,     null: false
    t.datetime "time_start",                                                           null: false
    t.datetime "time_end",                                                             null: false
    t.integer  "topic_id",       limit: 4
    t.integer  "topic_group_id", limit: 4,                                             null: false
    t.integer  "level_id",       limit: 4,                                             null: false
    t.decimal  "price",                        precision: 8, scale: 2,                 null: false
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.boolean  "free_lesson",                                          default: false
    t.text     "comment",        limit: 65535
    t.boolean  "pay_afterwards",                                       default: false, null: false
  end

  add_index "lessons", ["created_at"], name: "index_lessons_on_created_at", using: :btree
  add_index "lessons", ["time_start"], name: "index_lessons_on_time_start", using: :btree

  create_table "levels", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",      limit: 4,   default: 1, null: false
    t.string   "code",       limit: 255,             null: false
    t.string   "be",         limit: 255,             null: false
    t.string   "fr",         limit: 255,             null: false
    t.string   "ch",         limit: 255,             null: false
  end

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.integer "unsubscriber_id",   limit: 4
    t.string  "unsubscriber_type", limit: 255
    t.integer "conversation_id",   limit: 4
  end

  add_index "mailboxer_conversation_opt_outs", ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id", using: :btree
  add_index "mailboxer_conversation_opt_outs", ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type", using: :btree

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string   "subject",    limit: 255, default: ""
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string   "type",                 limit: 255
    t.text     "body",                 limit: 65535
    t.string   "subject",              limit: 255,   default: ""
    t.integer  "sender_id",            limit: 4
    t.string   "sender_type",          limit: 255
    t.integer  "conversation_id",      limit: 4
    t.boolean  "draft",                              default: false
    t.string   "notification_code",    limit: 255
    t.integer  "notified_object_id",   limit: 4
    t.string   "notified_object_type", limit: 255
    t.string   "attachment",           limit: 255
    t.datetime "updated_at",                                         null: false
    t.datetime "created_at",                                         null: false
    t.boolean  "global",                             default: false
    t.datetime "expires"
  end

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree
  add_index "mailboxer_notifications", ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type", using: :btree
  add_index "mailboxer_notifications", ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type", using: :btree
  add_index "mailboxer_notifications", ["type"], name: "index_mailboxer_notifications_on_type", using: :btree

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.integer  "receiver_id",     limit: 4
    t.string   "receiver_type",   limit: 255
    t.integer  "notification_id", limit: 4,                   null: false
    t.boolean  "is_read",                     default: false
    t.boolean  "trashed",                     default: false
    t.boolean  "deleted",                     default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "is_delivered",                default: false
    t.string   "delivery_method", limit: 255
    t.string   "message_id",      limit: 255
  end

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree
  add_index "mailboxer_receipts", ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type", using: :btree

  create_table "masterclasses", force: :cascade do |t|
    t.integer  "admin_id",   limit: 4
    t.datetime "time_start"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "offer_prices", force: :cascade do |t|
    t.integer  "offer_id",   limit: 4,                                       null: false
    t.integer  "level_id",   limit: 4,                                       null: false
    t.decimal  "price",                precision: 8, scale: 2, default: 0.0, null: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
  end

  create_table "offers", force: :cascade do |t|
    t.integer  "user_id",        limit: 4,     null: false
    t.integer  "topic_id",       limit: 4
    t.integer  "topic_group_id", limit: 4,     null: false
    t.string   "other_name",     limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "description",    limit: 65535
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "status",                limit: 4
    t.integer  "payment_type",          limit: 4
    t.datetime "transfert_date"
    t.float    "price",                 limit: 24
    t.integer  "lesson_id",             limit: 4
    t.integer  "mangopay_payin_id",     limit: 4
    t.datetime "execution_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_method",        limit: 4,     default: 3
    t.integer  "transfer_eleve_id",     limit: 4
    t.integer  "transfer_prof_id",      limit: 4
    t.integer  "transfer_bonus_id",     limit: 4
    t.float    "transfer_bonus_amount", limit: 24
    t.text     "transactions",          limit: 65535
  end

  create_table "pictures", force: :cascade do |t|
    t.string   "description",        limit: 255
    t.string   "image",              limit: 255
    t.integer  "gallery_id",         limit: 4,   null: false
    t.string   "gallery_token",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
  end

  create_table "postulations", force: :cascade do |t|
    t.boolean  "interview_ok",                  default: false
    t.boolean  "avatar_ok",                     default: false
    t.boolean  "gen_informations_ok",           default: false
    t.boolean  "offer_ok",                      default: false
    t.integer  "user_id",             limit: 4,                 null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "admin_id",            limit: 4
  end

  create_table "read_marks", force: :cascade do |t|
    t.integer  "readable_id",   limit: 4
    t.string   "readable_type", limit: 255, null: false
    t.integer  "reader_id",     limit: 4
    t.string   "reader_type",   limit: 255, null: false
    t.datetime "timestamp"
  end

  add_index "read_marks", ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "sender_id",   limit: 4
    t.integer  "subject_id",  limit: 4
    t.text     "review_text", limit: 65535
    t.integer  "note",        limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "topic_groups", force: :cascade do |t|
    t.string   "title",          limit: 255,                 null: false
    t.string   "level_code",     limit: 255,                 null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "topic_group_id", limit: 4
    t.boolean  "featured",                   default: false
    t.string   "picto",          limit: 255
  end

  create_table "topics", force: :cascade do |t|
    t.string   "title",          limit: 255,                 null: false
    t.integer  "topic_group_id", limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "topics_id",      limit: 4
    t.boolean  "featured",                   default: false
    t.string   "picto",          limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                  limit: 255,   default: "",            null: false
    t.string   "firstname",              limit: 255,   default: "",            null: false
    t.string   "lastname",               limit: 255,   default: "",            null: false
    t.date     "birthdate",                            default: '2016-01-01',  null: false
    t.text     "description",            limit: 65535,                         null: false
    t.string   "gender",                 limit: 255,   default: "Not telling", null: false
    t.string   "phone_number",           limit: 255,   default: "",            null: false
    t.string   "type",                   limit: 255,   default: "Student",     null: false
    t.integer  "level_id",               limit: 4,     default: 1
    t.boolean  "first_lesson_free",                    default: false
    t.boolean  "accepts_post_payments",                default: false
    t.string   "occupation",             limit: 255,   default: ""
    t.boolean  "postulance_accepted",                  default: false,         null: false
    t.string   "teacher_status",         limit: 255,   default: "Actif"
    t.string   "email",                  limit: 255,   default: "",            null: false
    t.string   "encrypted_password",     limit: 255,   default: "",            null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,             null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,     default: 0,             null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                                default: false
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size",       limit: 4
    t.datetime "avatar_updated_at"
    t.integer  "mango_id",               limit: 4
    t.datetime "last_seen"
    t.string   "time_zone",              limit: 255,   default: "UTC"
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.integer  "score",                  limit: 4,     default: 0
    t.integer  "response_rate",          limit: 4,     default: 0
    t.integer  "response_time",          limit: 4,     default: 0
    t.integer  "average_response_time",  limit: 4,     default: 0
    t.integer  "avatar_score",           limit: 4
    t.string   "phone_country_code",     limit: 255
    t.boolean  "sms_allowed",                          default: true
    t.boolean  "active",                               default: true
    t.boolean  "blocked",                              default: false
    t.text     "tokens",                 limit: 65535
    t.string   "authentication_token",   limit: 30
    t.string   "video_url",              limit: 255
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
