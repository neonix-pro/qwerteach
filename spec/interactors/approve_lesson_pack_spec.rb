require 'rails_helper'

RSpec.describe ApproveLessonPack do

  let(:lesson_pack) { create(:lesson_pack, :with_items, status: LessonPack::Status::PENDING_STUDENT) }
  before(:each) do
    allow_any_instance_of(LessonPack).to receive(:rate).and_return(10.0)
  end

  context 'One transaction' do
    let(:normal_transaction) { mango_transaction(credit: lesson_pack.amount) }
    let(:transactions) { [ normal_transaction ] }
    let(:payment_method) { :transfert }

    subject { ApproveLessonPack.run(lesson_pack: lesson_pack, transactions: transactions, payment_method: payment_method) }

    it 'change status to approved' do
      expect{ subject }.to change{ lesson_pack.status }.from('pending_student').to('paid')
    end

    it 'create lessons' do
      expect{ subject }.to change { lesson_pack.lessons.size }.from(0).to(lesson_pack.items.size)
      lesson_pack.lessons.each do |lesson|
        expect(lesson).to have_attributes({
          id: a_kind_of(Integer),
          teacher_id: lesson_pack.teacher_id,
          student_id: lesson_pack.student_id,
          topic_id: lesson_pack.topic_id,
          level_id: lesson_pack.level_id,
          price: lesson_pack.amount / lesson_pack.items.size
        })
      end

      lesson_pack.lessons.zip(lesson_pack.items) do |lesson, item|
        expect(lesson).to have_attributes({
          time_start: item.time_start,
          time_end: item.time_start + item.duration.minutes
        })
      end
    end

    it 'create payments' do
      expect { subject }.to change{ lesson_pack.payments.reload.size }.from(0).to(lesson_pack.items.size)
      lesson_pack.payments.each do |payment|
        expect(payment).to have_attributes({
          id: a_kind_of(Integer),
          payment_method: 'wallet',
          status: 'locked',
          mangopay_payin_id: normal_transaction.id.to_i,
          price: lesson_pack.amount / lesson_pack.items.size
        })
      end
    end
  end

  context 'Two transactions' do
    let(:normal_transaction) { mango_transaction(id: '1', credit: lesson_pack.amount * 0.8) }
    let(:bonus_transaction) { mango_transaction(id: '2', credit: lesson_pack.amount * 0.2) }
    let(:transactions) { [ normal_transaction, bonus_transaction ] }
    let(:payment_method) { :transfert }

    subject { ApproveLessonPack.run(lesson_pack: lesson_pack, transactions: transactions, payment_method: payment_method) }

    it 'create payments with bonus transactions' do
      expect { subject }.to change{ lesson_pack.payments.reload.size }.from(0).to(lesson_pack.items.size)
      expect(lesson_pack.payments.first).to have_attributes({
        id: a_kind_of(Integer),
        payment_method: 'wallet',
        status: 'locked',
        transfer_eleve_id: normal_transaction.id.to_i,
        transfer_bonus_id: bonus_transaction.id.to_i,
        transfer_bonus_amount: lesson_pack.amount * 0.2 / lesson_pack.items.size,
        price: lesson_pack.amount / lesson_pack.items.size
      })
    end
  end

end