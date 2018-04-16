FactoryGirl.define do
  factory :lesson_pack do
    status LessonPack::Status::DRAFT
    teacher { build(:teacher) }
    student { build(:student) }
    topic { build(:topic) }
    level { build(:level) }
    discount 1
    trait :with_items do
      #association :items, factory: :lesson_pack_item, strategy: :build
      items { FactoryGirl.build_list(:lesson_pack_item, 5) }
    end
  end

  factory :lesson_pack_item do
    time_start { rand(30).days.since }
    duration { 60 }
  end
end
