require "administrate/base_dashboard"

module Reports
  class ActivityReportDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      period: Field::String,
      lessons_count: Field::Number,
      lessons_amount: Field::Number,
      students_count: Field::Number,
      new_students_count: Field::Number,
      teachers_count: Field::Number,
      new_teachers_count: Field::Number,
      disputes_count: Field::Number,
    }.freeze

    COLLECTION_ATTRIBUTES = ATTRIBUTE_TYPES.keys

    SHOW_PAGE_ATTRIBUTES = []

    FORM_ATTRIBUTES = []
  end
end