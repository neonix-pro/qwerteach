FactoryBot.define do
  factory :lesson do

    student{ FactoryBot.create(:student) }
    teacher{ FactoryBot.create(:teacher) }
    status 0
    time_start { 1.day.since }
    time_end { 1.day.since + 2.hours }
    topic { FactoryBot.create(:topic) }
    topic_group { FactoryBot.create(:topic_group) }
    level { FactoryBot.create(:level_5) }
    price 30.0
    free_lesson false

    trait :paid do
      status { Lesson.statuses[:created] }
      payments { FactoryBot.build_list :payment, 1 }
    end

    trait :pending_student do
      status { Lesson.statuses[:pending_student] }
    end

    trait :pending_teacher do
      status { Lesson.statuses[:pending_teacher] }
    end

    trait :refused do
      status { Lesson.statuses[:refused] }
    end

    trait :created do
      status { Lesson.statuses[:created] }
    end

    trait :pack do
      pack
    end

    trait :today do
      time_start { Time.current.midday }
      time_end { Time.current.midday + 2.hours }
    end

  end
end