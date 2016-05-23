require "administrate/base_dashboard"

class LessonDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    student: Field::BelongsTo.with_options(class_name: "User"),
    teacher: Field::BelongsTo.with_options(class_name: "User"),
    topic_group: Field::BelongsTo,
    topic: Field::BelongsTo,
    level: Field::BelongsTo,
    payments: Field::HasMany,
    bbb_room: Field::HasOne,
    id: Field::Number,
    student_id: Field::Number,
    teacher_id: Field::Number,
    status: Field::String.with_options(searchable: false),
    time_start: Field::DateTime,
    time_end: Field::DateTime,
    price: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :student,
    :teacher,
    :topic_group,
    :topic,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :student,
    :teacher,
    :topic_group,
    :topic,
    :level,
    :payments,
    :bbb_room,
    :id,
    :student_id,
    :teacher_id,
    :status,
    :time_start,
    :time_end,
    :price,
    :created_at,
    :updated_at,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :student,
    :teacher,
    :topic_group,
    :topic,
    :level,
    :payments,
    :bbb_room,
    :student_id,
    :teacher_id,
    :status,
    :time_start,
    :time_end,
    :price,
  ]

  # Overwrite this method to customize how lessons are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(lesson)
  #   "Lesson ##{lesson.id}"
  # end
end
