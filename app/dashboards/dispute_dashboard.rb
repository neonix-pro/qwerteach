require "administrate/base_dashboard"

class DisputeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    status: Field::String,
    user: Field::BelongsTo.with_options(class_name: 'User'),
    lesson: Field::BelongsTo,
    payments: Field::HasMany, # .with_options(class_name: 'Payment'),
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :status,
    :user,
    :lesson
  ]

  COLLECTION_SCOPES = [
    :all,
    :started,
    :finished
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :status,
    :user,
    :lesson,
    :payments,
    :created_at,
    :updated_at
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user
  ]

  # Overwrite this method to customize how disputes are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(dispute)
    "Dispute #{dispute.user.try(:name) || "##{dispute.id}"}"
  end
end
