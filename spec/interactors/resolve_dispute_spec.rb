require 'rails_helper'

RSpec.describe ResolveDispute do

  describe 'There is a sharing of money' do
    let(:student){ create(:student, email: FFaker::Internet.email) }
    let(:teacher){ create(:teacher, email: FFaker::Internet.email) }
    let(:lesson){ create(:lesson, student: student, teacher: teacher) }

    before :each do
      #@lesson = create(:lesson, student: student, teacher: teacher)
      Mango::SaveAccount.run attributes_for(:mango_user).merge(user: student)
      Mango::PayinTestCard.run(user: student, amount: 45)
      student.reload
      Mango::SaveAccount.run attributes_for(:mango_user).merge(user: teacher)
      expect_any_instance_of(ResolveDispute).to receive(:send_notifications)
    end

    it 'moves a part of money to the teacher', vcr: true do
      PayLessonByTransfert.run(user: student, lesson: lesson)
      expect(lesson.payments.any?{|p| p.locked?}).to be_truthy
      dispute = DisputeLesson.run(user: student, lesson: lesson).result
      expect(lesson.reload.payments.any?{|p| p.disputed?}).to be_truthy
      student.reload
      expect(teacher.normal_wallet.balance.amount).to eq(0)
      expect(student.normal_wallet.balance.amount).to eq(1500)
      expect(student.transaction_wallet.balance.amount).to eq(3000)
      ResolveDispute.run(dispute: dispute, amount: lesson.price - 10)
      expect(dispute.finished?).to be_truthy
      student.reload
      teacher.reload
      expect(student.normal_wallet.balance.amount).to eq(2500)
      expect(student.transaction_wallet.balance.amount).to eq(0)
      expect(teacher.normal_wallet.balance.amount).to eq(2000)
    end

    it 'moves all money to the teacher', vcr: true do
      PayLessonByTransfert.run(user: student, lesson: lesson)
      expect(lesson.payments.any?{|p| p.locked?}).to be_truthy
      dispute = DisputeLesson.run(user: student, lesson: lesson).result
      expect(lesson.reload.payments.any?{|p| p.disputed?}).to be_truthy
      student.reload
      expect(teacher.normal_wallet.balance.amount).to eq(0)
      expect(student.normal_wallet.balance.amount).to eq(1500)
      expect(student.transaction_wallet.balance.amount).to eq(3000)
      ResolveDispute.run(dispute: dispute, amount: lesson.price)
      expect(dispute.finished?).to be_truthy
      student.reload
      teacher.reload
      expect(student.normal_wallet.balance.amount).to eq(1500)
      expect(student.transaction_wallet.balance.amount).to eq(0)
      expect(teacher.normal_wallet.balance.amount).to eq(3000)
    end

  end

  describe 'Error processing' do
    let(:dispute) { create :dispute }

    it 'can not re-resolve a dispute' do
      dispute.finished!
      dispute_resolve = ResolveDispute.run(dispute: dispute, amount: 0)
      expect(dispute_resolve.valid?).to be_falsey
    end

    it 'The translation should be less than the cost of the lesson' do
      dispute_resolve = ResolveDispute.run(dispute: dispute, amount: dispute.lesson.price + 1)
      expect(dispute_resolve.valid?).to be_falsey
    end

    it 'The translation must be greater than zero' do
      dispute_resolve = ResolveDispute.run(dispute: dispute, amount: 0)
      expect(dispute_resolve.valid?).to be_falsey
    end
  end
end




