FactoryGirl.define do
  factory :conversation do
    subject FFaker::Product.brand
  end
end