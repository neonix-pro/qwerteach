require 'rails_helper'

RSpec.describe CancelLesson do
  let(:student) { create(:student) }
  let(:teacher) { create(:teacher) }

  shared_examples 'call refund lesson' do
    it 'calls RefundLesson successfully' do
      expect(RefundLesson).to receive(:run)
        .with(hash_including(lesson: lesson, user: user))
        .and_return(TestValidInteraction.run(res: true))
      CancelLesson.run(user: user, lesson: lesson)
    end
  end

  shared_examples 'invalid result' do
    it 'has invalid result' do
      expect(CancelLesson.run(user: user, lesson: lesson)).to_not be_valid
    end
  end

  describe 'Default' do
    let(:lesson) { create(:lesson, student: student, teacher: teacher, status: :created, time_start: 5.days.since, time_end: 6.days.since) }
    let(:user) { teacher }

    include_examples 'call refund lesson'
  end

  describe 'Pending student' do
    let(:lesson) { create(:lesson, :pending_teacher, student: student, teacher: teacher, time_start: 5.days.since, time_end: 6.days.since) }
    let(:user) { student }

    include_examples 'call refund lesson'
  end

  describe 'Pending student' do
    let(:lesson) { create(:lesson, :pending_student, student: student, teacher: teacher, time_start: 5.days.since, time_end: 6.days.since) }
    let(:user) { student }

    include_examples 'call refund lesson'
  end

  describe 'less than 24 hours to start' do
    let(:lesson) { create(:lesson, :paid, student: student, teacher: teacher, time_start: 2.hours.since, time_end: 3.hours.since) }
    let(:user) { student }

    include_examples 'invalid result'
  end

end