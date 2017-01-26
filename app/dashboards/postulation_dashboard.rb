require "administrate/base_dashboard"

class PostulationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
      id: Field::Number,
      user: Field::BelongsTo.with_options(class_name: "Teacher"),
      teacher: Field::BelongsTo.with_options(class_name: "Teacher"),
      interview_ok: Field::Boolean,
      avatar_ok: Field::Boolean,
      gen_informations_ok: Field::Boolean,
      offer_ok: Field::Boolean,
      user_id: Field::Number,
      created_at: Field::DateTime,
      updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
      :teacher,
      :id,
      :interview_ok,
      :avatar_ok,
      :gen_informations_ok,
      :offer_ok
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
      :user,
      :id,
      :teacher,
      :interview_ok,
      :avatar_ok,
      :gen_informations_ok,
      :offer_ok,
      :created_at,
      :updated_at,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
      #:user,
      :interview_ok,
      :avatar_ok,
      :gen_informations_ok,
      :offer_ok,
  ]

  # Overwrite this method to customize how postulations are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(postulation)
    "Status: #{postulation.ok_fields.count} / #{postulation.admin_fields.count}"
  end
end
