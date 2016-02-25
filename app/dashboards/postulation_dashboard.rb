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
      interview_ok: Field::Boolean,
      avatar_ok: Field::Boolean,
      gen_informations_ok: Field::Boolean,
      advert_ok: Field::Boolean,
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
      :user_id,
      :id,
      :interview_ok,
      :avatar_ok,
      :gen_informations_ok,
      :advert_ok
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
      :id,
      :interview_ok,
      :avatar_ok,
      :gen_informations_ok,
      :advert_ok,
      :user_id,
      :created_at,
      :updated_at,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
      :interview_ok,
      :avatar_ok,
      :gen_informations_ok,
      :advert_ok,
      :user_id,
  ]

  # Overwrite this method to customize how postulations are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(postulation)
  #   "Postulation ##{postulation.id}"
  # end
end
