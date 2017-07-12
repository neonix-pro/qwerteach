require 'rails_helper'

RSpec.describe ResolveDispute do

  describe 'Money transferring' do
    let(:student){ create(:student, email: FFaker::Internet.email) }
    let(:teacher){ create(:teacher, email: FFaker::Internet.email) }
    let(:lesson){ create(:lesson, student: student, teacher: teacher, price: 30) }


    before :each do
      #@lesson = create(:lesson, student: student, teacher: teacher)
      Mango::SaveAccount.run attributes_for(:mango_user).merge(user: student)
      Mango::PayinTestCard.run(user: student, amount: 45)
      student.reload
      Mango::SaveAccount.run attributes_for(:mango_user).merge(user: teacher)
      expect_any_instance_of(ResolveDispute).to receive(:send_notifications)
    end

    context 'Without bonus wallet' do

      it 'moves a part of money to the teacher', vcr: true do
        PayLessonByTransfert.run(user: student, lesson: lesson)
        DisputeLesson.run(user: student, lesson: lesson)
        resolve = ResolveDispute.run(dispute: lesson.reload.dispute, amount: lesson.price - 10)
        expect(resolve).to be_valid
        student.reload
        teacher.reload
        #expect(student.normal_wallet.balance.amount).to eq(2500)
        expect(student.bonus_wallet.balance.amount).to eq(0)
        expect(student.transaction_wallet.balance.amount).to eq(0)
        expect(teacher.normal_wallet.balance.amount).to eq(2000)
      end

      it 'moves all money to the teacher', vcr: true do
        PayLessonByTransfert.run(user: student, lesson: lesson)
        DisputeLesson.run(user: student, lesson: lesson)
        resolve = ResolveDispute.run(dispute: lesson.reload.dispute, amount: lesson.price)
        expect(resolve).to be_valid
        student.reload
        teacher.reload
        expect(student.normal_wallet.balance.amount).to eq(1500)
        expect(student.transaction_wallet.balance.amount).to eq(0)
        expect(teacher.normal_wallet.balance.amount).to eq(3000)
      end

    end

    context 'With bonus wallet' do

      it 'returns bonus and normal part to the relevant wallets', vcr: true do
        Mango::PayinTestCard.run(user: student, amount: 10, wallet: 'bonus')
        PayLessonByTransfert.run(user: student.reload, lesson: lesson)
        DisputeLesson.run(user: student, lesson: lesson).result
        resolve = ResolveDispute.run(dispute: lesson.reload.dispute, amount: 10)
        expect(resolve).to be_valid
        student.reload
        teacher.reload
        expect(student.normal_wallet.balance.amount).to eq(3500)
        expect(student.bonus_wallet.balance.amount).to eq(1000)
        expect(student.transaction_wallet.balance.amount).to eq(0)
        expect(teacher.normal_wallet.balance.amount).to eq(1000)
      end
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




