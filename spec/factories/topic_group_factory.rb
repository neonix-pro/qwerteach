FactoryGirl.define do
  factory :topic_group do
    title{ FFaker::Lorem.word }
    level_code{ FFaker::Lorem.word.downcase }
  end
end