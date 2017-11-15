require "administrate/base_dashboard"

class MasterclassDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    bbb_room: Field::HasOne,
    admin: Field::BelongsTo.with_options(class_name: "User"),
    #admin_id: Field::Number,
    time_start: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :bbb_room,
    :admin,
    :id,
    #:admin_id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :bbb_room,
    :admin,
    :id,
    #:admin_id,
    :time_start,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    #:bbb_room,
    #:admin,
    #:admin_id,
    :time_start,
  ].freeze

  # Overwrite this method to customize how masterclasses are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(masterclass)
  #   "Masterclass ##{masterclass.id}"
  # end
end
