require 'rails_helper'

RSpec.describe Lesson, type: :model do



  describe 'States' do

    describe 'Normal' do
      let(:lesson){ create(:lesson) }
      it('not paid'){ expect(lesson).to_not be_paid }
      it('not prepaid'){ expect(lesson).to_not be_prepaid }
      it('can not start'){ expect(lesson).to_not be_can_start }
    end

    describe 'Free' do
      let(:lesson){ create(:lesson, free_lesson: true) }

      it('is paid'){ expect(lesson).to be_paid }
      it('can start'){ expect(lesson).to be_can_start }
    end

    describe 'all payments paid' do
      let(:lesson){ create(:lesson, payments: build_list(:payment, 3, status: :paid)) }
      it('is paid'){ expect(lesson).to be_paid }
      it('is not prepaid'){ expect(lesson).to_not be_prepaid }
      it('can start'){ expect(lesson).to be_can_start }
    end

    describe 'all payments locked' do
      let(:lesson){ create(:lesson, payments: build_list(:payment, 3, status: :locked)) }
      it('is not paid'){ expect(lesson).to_not be_paid }
      it('is prepaid'){ expect(lesson).to be_prepaid }
      it('can start'){ expect(lesson).to be_can_start }
    end

    describe 'Pay afterwards'do
      let(:lesson){ create(:lesson, pay_afterwards: true) }
      it('is not paid'){ expect(lesson).to_not be_paid }
      it('is not prepaid'){ expect(lesson).to_not be_prepaid }
      it('can start'){ expect(lesson).to be_can_start }
    end

  end

end