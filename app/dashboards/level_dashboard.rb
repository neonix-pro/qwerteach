require "administrate/base_dashboard"

class LevelDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    users: Field::HasMany,
    advert_prices: Field::HasMany,
    degree: Field::HasOne,
    id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    level: Field::Number,
    code: Field::String,
    be: Field::String,
    fr: Field::String,
    ch: Field::String,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :users,
    :advert_prices,
    :degree,
    :id,
    :be,
    :fr,
    :ch,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :users,
    :advert_prices,
    :degree,
    :id,
    :created_at,
    :updated_at,
    :level,
    :code,
    :be,
    :fr,
    :ch,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :users,
    :advert_prices,
    :degree,
    :level,
    :code,
    :be,
    :fr,
    :ch,
  ]

  # Overwrite this method to customize how levels are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(level)
  #   "Level ##{level.id}"
  # end
end
