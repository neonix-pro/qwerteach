require "administrate/base_dashboard"

class GlobalRequestDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    student: Field::BelongsTo.with_options(class_name: "User"),
    topic: Field::BelongsTo,
    level: Field::BelongsTo,
    id: Field::Number,
    user_id: Field::Number,
    description: Field::Text,
    status: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    expiry_date: Field::DateTime,
    price_max: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :student,
    :topic,
    :level,
    :price_max,
    :expiry_date,
    :status
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :student,
    :topic,
    :level,
    :id,
    :user_id,
    :description,
    :status,
    :created_at,
    :updated_at,
    :expiry_date,
    :price_max,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :student,
    :topic,
    :level,
    :user_id,
    :description,
    :status,
    :expiry_date,
    :price_max,
  ].freeze

  # Overwrite this method to customize how global requests are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(global_request)
  #   "GlobalRequest ##{global_request.id}"
  # end
end
