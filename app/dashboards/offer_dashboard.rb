require "administrate/base_dashboard"

class OfferDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    topic: Field::BelongsTo,
    offer_prices: Field::HasMany,
    id: Field::Number,
    topic_group_id: Field::Number,
    topic_group: Field::BelongsTo,
    other_name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    #:user,
    :topic_group,
    :topic,
    :offer_prices,
    :id,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :topic,
    :offer_prices,
    :id,
    :topic_group_id,
    :other_name,
    :created_at,
    :updated_at,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :topic,
    :offer_prices,
    :topic_group_id,
    :other_name,
  ]

  # Overwrite this method to customize how offers are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(offer)
    "#{offer.topic.topic_group.title}: #{offer.topic.title}"
  end
end
