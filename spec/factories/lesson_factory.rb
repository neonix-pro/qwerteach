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

  end
end