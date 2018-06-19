FactoryBot.define do
  factory :topic do
    title{ FFaker::Lorem.word }
    topic_group{ FactoryBot.build(:topic_group) }
  end
end