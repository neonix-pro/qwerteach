FactoryGirl.define do
  factory :lesson do

    student{ FactoryGirl.build(:student, email: FFaker::Internet.email) }
    teacher{ FactoryGirl.build(:teacher, email: FFaker::Internet.email) }
    status 0
    time_start { 1.day.since }
    time_end { 1.day.since + 2.hours }
    topic { FactoryGirl.build(:topic) }
    topic_group { FactoryGirl.build(:topic_group) }
    level { FactoryGirl.build(:level_5) }
    price 30.0
    free_lesson false

  end
end