FactoryGirl.define do
  factory :offer_price do
    level
    price{ rand(10..90) * 10 }
  end
end