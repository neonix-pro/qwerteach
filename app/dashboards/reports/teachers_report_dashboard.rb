require "administrate/base_dashboard"

module Reports
  class TeachersReportDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      id: Field::Number,
      avatar_file_name: Field::String,
      first_name: Field::String,
      lessons_count: Field::Number,
      total_lessons_count: Field::Number,
      lessons_amount: Field::Number,
      total_lessons_amount: Field::Number,
      students_count: Field::Number,
      total_student_count: Field::Number,
      first_lesson_date: Field::DateTime,
      last_lesson_date: Field::DateTime,
      last_seen: Field::DateTime
    }.freeze

    COLLECTION_ATTRIBUTES = ATTRIBUTE_TYPES.keys

    SHOW_PAGE_ATTRIBUTES = []

    FORM_ATTRIBUTES = []
  end
end