require 'rails_helper'

RSpec.describe DisputeLesson do

  let(:lesson){ create(:lesson) }
  let!(:payment1){ create(:payment, lesson: lesson, status: :locked) }
  let!(:payment2){ create(:payment, lesson: lesson, status: :locked) }

  context 'correct inputs' do
    subject { DisputeLesson.run(user: lesson.student, lesson: lesson) }
    it 'creates dispute and set payments status to disputed' do
      expect(subject).to be_valid
      expect(lesson.reload.dispute).to be
      expect(payment1.reload.status).to eq('disputed')
      expect(payment2.reload.status).to eq('disputed')
    end
  end

  context 'lesson already disputed' do
    let(:dispute){ create(:dispute) }
    let(:lesson){ dispute.lesson }
    subject { DisputeLesson.run(user: lesson.student, lesson: lesson) }
    it 'does not create new dispute' do
      expect(subject).to_not be_valid
      expect(lesson.reload.dispute).to eq(dispute)
    end
  end
end