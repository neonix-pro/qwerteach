require "administrate/base_dashboard"

class ReceiptDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    notification: Field::BelongsTo.with_options(class_name: "Notification"),
    receiver: Field::Polymorphic,
    message: Field::BelongsTo.with_options(class_name: "Message"),
    id: Field::Number,
    notification_id: Field::Number,
    is_read: Field::Boolean,
    trashed: Field::Boolean,
    deleted: Field::Boolean,
    mailbox_type: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :notification,
    :receiver,
    :message,
    :id,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :notification,
    :receiver,
    :message,
    :id,
    :notification_id,
    :is_read,
    :trashed,
    :deleted,
    :mailbox_type,
    :created_at,
    :updated_at,
  ]

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :notification,
    :receiver,
    :message,
    :notification_id,
    :is_read,
    :trashed,
    :deleted,
    :mailbox_type,
  ]

  # Overwrite this method to customize how receipts are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(receipt)
  #   "Receipt ##{receipt.id}"
  # end
end
