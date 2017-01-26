FactoryGirl.define do
  factory :offer do
    user{ FactoryGirl.build(:teacher, email: FFaker::Internet.email) }
    topic{ FactoryGirl.build(:topic) }
    topic_group{ FactoryGirl.build(:topic_group) }
    other_name{ FFaker::Education.major }
    description{ FFaker::Lorem.phrase }
    offer_prices do
      [
        FactoryGirl.build(:offer_price, level: FactoryGirl.build(:level_5), price: 10),
        FactoryGirl.build(:offer_price, level: FactoryGirl.build(:level_10), price: 20),
        FactoryGirl.build(:offer_price, level: FactoryGirl.build(:level_15), price: 30)
      ]
    end
  end
end