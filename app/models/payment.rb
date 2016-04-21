class Payment < ActiveRecord::Base
  TYPE = ["Pre-payment", "Post-payment"]
  STATUS_TYPE = ["Pending", "Paid", "Canceled", "Blocked"]
  belongs_to :lesson

end
