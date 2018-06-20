FactoryBot.define do
  factory :payment do
    status :paid
    transfert_date {Time.current}
    price 100
    lesson { FactoryBot.build(:lesson) }
    mangopay_payin_id { rand(10000..99999) }
    payment_method :creditcard
    payment_type :prepayment
  end
end