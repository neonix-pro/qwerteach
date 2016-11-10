FactoryGirl.define do
  factory :topic do
    title{ FFaker::Lorem.word }
    topic_group{ FactoryGirl.build(:topic_group) }
  end
end