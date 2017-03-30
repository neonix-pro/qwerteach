require 'rails_helper'

RSpec.describe AcceptLesson do

  describe 'Teacher' do

    let(:user){ create(:teacher) }
    let(:lesson){ create(:lesson, teacher: user, status: :pending_teacher) }

    it 'set status to pending_student unless pay afterwards' do
      accepting = AcceptLesson.run(user: user, lesson: lesson)
      expect(accepting).to be_valid
      expect(lesson.reload.status).to eq('pending_student')
    end

    it 'set status to created if lesson paid' do
      create(:payment, lesson: lesson)
      accepting = AcceptLesson.run(user: user, lesson: lesson)
      expect(accepting).to be_valid
      expect(lesson.reload.status).to eq('created')
    end

    it 'set status to created for free lesson' do
      lesson.update(free_lesson: true)
      accepting = AcceptLesson.run(user: user, lesson: lesson)
      expect(accepting).to be_valid
      expect(lesson.reload.status).to eq('created')
    end

    it 'set status to created if pay afterwards' do
      lesson.update(pay_afterwards: true)
      accepting = AcceptLesson.run(user: user, lesson: lesson)
      expect(accepting).to be_valid
      expect(lesson.reload.status).to eq('created')
    end
  end

  describe 'Student' do
    let(:user){ create(:student) }
    let(:lesson){ create(:lesson, student: user, status: :pending_student) }

    it 'set status to created if pay afterwards' do
      lesson.update(pay_afterwards: true)
      accepting = AcceptLesson.run(user: user, lesson: lesson)
      expect(accepting).to be_valid
      expect(lesson.reload.status).to eq('created')
    end

    it 'returns error when lesson is not paid and can not be paid afterwards' do
      accepting = AcceptLesson.run(user: user, lesson: lesson)
      expect(accepting).to_not be_valid
      expect(accepting.errors[:base]).to eq(['Needs to pay this lesson before'])
    end

    it 'set status to created if lesson is free' do
      lesson.update(free_lesson: true)
      accepting = AcceptLesson.run(user: user, lesson: lesson)
      expect(accepting).to be_valid
      expect(lesson.reload.status).to eq('created')
    end

    it 'set status to created if lesson paid' do
      create(:payment, lesson: lesson)
      accepting = AcceptLesson.run(user: user, lesson: lesson)
      expect(accepting).to be_valid
      expect(lesson.reload.status).to eq('created')
    end

  end

end