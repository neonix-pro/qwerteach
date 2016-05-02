class Payment < ActiveRecord::Base
  #TYPE = ["Pre-payment", "Post-payment"] 
  enum type: [:PrePayment, :PostPayment]
  STATUS_TYPE = ["Pending", "Paid", "Canceled", "Blocked"]
  belongs_to :lesson

end
