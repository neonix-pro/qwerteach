FactoryGirl.define do
  factory :lesson do

    student{ FactoryGirl.create(:student) }
    teacher{ FactoryGirl.create(:teacher) }
    status 0
    time_start { 1.day.since }
    time_end { 1.day.since + 2.hours }
    topic { FactoryGirl.create(:topic) }
    topic_group { FactoryGirl.create(:topic_group) }
    level { FactoryGirl.create(:level_5) }
    price 30.0
    free_lesson false

    trait :paid do
      status { Lesson.statuses[:created] }
      payments { FactoryGirl.build_list :payment, 1 }
    end

    trait :pending_student do
      status { Lesson.statuses[:pending_student] }
    end

    trait :pending_teacher do
      status { Lesson.statuses[:pending_teacher] }
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