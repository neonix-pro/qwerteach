require "administrate/base_dashboard"

module Reports
  class LessonsReportDashboard < Administrate::BaseDashboard

    ATTRIBUTE_TYPES = {
      period: Field::String,
      total_count: Field::Number,
      created_count: Field::Number,
      created_amount: Field::Number,
      expired_count: Field::Number,
      unpaid_count: Field::Number,
      unpaid_amount: Field::Number,
      students_count: Field::Number,
      new_students_count: Field::Number,
      teachers_count: Field::Number,
      new_teachers_count: Field::Number,
    }

    COLLECTION_ATTRIBUTES = ATTRIBUTE_TYPES.keys

    SHOW_PAGE_ATTRIBUTES = []

    FORM_ATTRIBUTES = []

  end
end