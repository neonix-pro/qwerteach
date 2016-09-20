FactoryGirl.define do
  factory :advert do
    user{ FactoryGirl.build(:teacher, email: FFaker::Internet.email) }
    topic{ FactoryGirl.build(:topic) }
    topic_group{ FactoryGirl.build(:topic_group) }
    other_name{ FFaker::Education.major }
    description{ FFaker::Lorem.phrase }
    advert_prices do
      [
        FactoryGirl.build(:advert_price, level: FactoryGirl.build(:level_5), price: 10),
        FactoryGirl.build(:advert_price, level: FactoryGirl.build(:level_10), price: 20),
        FactoryGirl.build(:advert_price, level: FactoryGirl.build(:level_15), price: 30)
      ]
    end
  end
end