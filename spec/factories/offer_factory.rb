FactoryBot.define do
  factory :offer do
    user{ FactoryBot.build(:teacher, email: FFaker::Internet.email) }
    topic{ FactoryBot.build(:topic) }
    topic_group{ FactoryBot.build(:topic_group) }
    other_name{ FFaker::Education.major }
    description{ FFaker::Lorem.phrase }
    offer_prices do
      [
        FactoryBot.build(:offer_price, level: FactoryBot.build(:level_5), price: 10),
        FactoryBot.build(:offer_price, level: FactoryBot.build(:level_10), price: 20),
        FactoryBot.build(:offer_price, level: FactoryBot.build(:level_15), price: 30)
      ]
    end
  end
end