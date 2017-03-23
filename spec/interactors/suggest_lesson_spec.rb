require 'rails_helper'

RSpec.describe SuggestLesson do

  let(:teacher){ create(:teacher) }
  let(:student){ create(:student) }
  let(:offer){ create(:offer, user: teacher) }

  let(:params) do
    {
      user: teacher,
      student_id: student.id,
      time_start: 1.day.since,
      hours: 3,
      minutes: 30,
      topic_id: offer.topic_id,
      price: 30,
      level_id: offer.levels.find_by(level: 5).id
    }
  end

  it 'creates lesson with pending_student status' do
    proposal = SuggestLesson.run(params)

    expect(proposal).to be_valid

    lesson = Lesson.last
    expect(lesson.price).to eq(30)
    expect(lesson.status).to eq('pending_student')
    expect(lesson.topic_id).to eq(offer.topic_id)
    expect(lesson.topic_group_id).to eq(offer.topic.topic_group_id)
    expect(lesson.level_id).to eq(offer.levels.find_by(level: 5).id)
    expect(lesson.pay_afterwards).to be false

    duration = Duration.new(lesson.time_end - lesson.time_start)
    expect(duration.total_hours).to eq(3)
    expect(duration.minutes).to eq(30)
  end

  it 'returns error for students without payments' do
    proposal = SuggestLesson.run(params.merge(pay_afterwards: true))
    expect(proposal).to_not be_valid
    expect(proposal.errors[:pay_afterwards]).to eq(['Can\'t be applicable for selected student'])
  end

  it 'creates lesson with pay_afterwards flag for a student with payments' do
    create :payment, lesson: create(:lesson, student: student)
    proposal = SuggestLesson.run(params.merge(pay_afterwards: true))
    expect(proposal).to be_valid
    expect(Lesson.last.pay_afterwards).to be true
  end

  it 'returns validation errors when durstion is 0' do
    proposal = SuggestLesson.run(params.merge(hours: 0, minutes: 0))
    expect(proposal).to_not be_valid
  end

end