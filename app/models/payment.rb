class Payment < ActiveRecord::Base
  #TYPE = ["Pre-payment", "Post-payment"] 
  enum type: [:prepayment, :postpayment]
  #STATUS_TYPE = ["Pending", "Paid", "Canceled", "Blocked"]
  enum status_type: [:pending, :paid, :canceled, :blocked]
  belongs_to :lesson

end
