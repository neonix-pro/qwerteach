require "administrate/base_dashboard"

class BbbRoomDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    owner: Field::Polymorphic,
    server: Field::BelongsTo.with_options(class_name: "BigbluebuttonServer"),
    recordings: Field::HasMany.with_options(class_name: "BigbluebuttonRecording"),
    metadata: Field::HasMany.with_options(class_name: "BigbluebuttonMetadata"),
    room_options: Field::HasOne,
    lesson: Field::BelongsTo,
    id: Field::Number,
    server_id: Field::Number,
    meetingid: Field::String,
    name: Field::String,
    attendee_key: Field::String,
    moderator_key: Field::String,
    welcome_msg: Field::String,
    logout_url: Field::String,
    voice_bridge: Field::String,
    dial_number: Field::String,
    max_participants: Field::Number,
    private: Field::Boolean,
    external: Field::Boolean,
    param: Field::String,
    record_meeting: Field::Boolean,
    duration: Field::Number,
    attendee_api_password: Field::String,
    moderator_api_password: Field::String,
    create_time: Field::String.with_options(searchable: false),
    moderator_only_message: Field::String,
    auto_start_recording: Field::Boolean,
    allow_start_stop_recording: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :owner,
    :server,
    :recordings,
    :metadata,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :owner,
    :server,
    :recordings,
    :metadata,
    :room_options,
    :lesson,
    :id,
    :server_id,
    :meetingid,
    :name,
    :attendee_key,
    :moderator_key,
    :welcome_msg,
    :logout_url,
    :voice_bridge,
    :dial_number,
    :max_participants,
    :private,
    :external,
    :param,
    :record_meeting,
    :duration,
    :attendee_api_password,
    :moderator_api_password,
    :create_time,
    :moderator_only_message,
    :auto_start_recording,
    :allow_start_stop_recording,
    :created_at,
    :updated_at,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :owner,
    :server,
    :recordings,
    :metadata,
    :room_options,
    :lesson,
    :server_id,
    :meetingid,
    :name,
    :attendee_key,
    :moderator_key,
    :welcome_msg,
    :logout_url,
    :voice_bridge,
    :dial_number,
    :max_participants,
    :private,
    :external,
    :param,
    :record_meeting,
    :duration,
    :attendee_api_password,
    :moderator_api_password,
    :create_time,
    :moderator_only_message,
    :auto_start_recording,
    :allow_start_stop_recording,
  ]

  # Overwrite this method to customize how bbb rooms are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(bbb_room)
  #   "BbbRoom ##{bbb_room.id}"
  # end
end
