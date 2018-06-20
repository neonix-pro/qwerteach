require 'rails_helper'

RSpec.describe CreateLessonRequest do

  before :each do
    @user = FactoryBot.create(:student, email: FFaker::Internet.email)
    @teacher = FactoryBot.create(:teacher, email: FFaker::Internet.email)
    @offer = FactoryBot.create(:offer, user: @teacher)
  end

  it 'create draft version of lesson' do
    creation = CreateLessonRequest.run({
      student_id: @user.id,
      teacher_id: @teacher.id,
      time_start: 1.day.ago,
      hours: 3,
      minutes: 30,
      topic_id: @offer.topic_id,
      level_id: @offer.offer_prices.map(&:level).find{|l| l.level == 5 }.id
    })

    lesson = Lesson.drafts(@user).first.try(:restore)
    expect(lesson).to be
    expect(lesson.id).to be_nil
    expect(lesson.price).to eq( 10 * 3.5 )
    expect(lesson.topic_id).to eq(@offer.topic_id)
    expect(lesson.topic_group_id).to eq(@offer.topic.topic_group_id)

    duration = Duration.new(lesson.time_end - lesson.time_start)
    expect(duration.total_hours).to eq(3)
    expect(duration.minutes).to eq(30)
  end


end