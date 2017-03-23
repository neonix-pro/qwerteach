require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do

  describe 'Create' do
    let(:user){ create(:student, mango_id: '123') }
    let(:lesson){ create(:lesson, student: user) }

    before(:each){ sign_in user }

    it 'calls PayLessonByTransfert' do
      expect(PayLessonByTransfert).to receive(:run).with({user: user, lesson: lesson, wallet: 'transaction'}).and_return(TestValidInteraction.run)
      post :create, lesson_id: lesson.id, mode: 'transfert', format: :js
    end

    it 'calls Mango::PayinBancontact' do
      expect(Mango::PayinBancontact).to receive(:run).with({
        user: user, amount: lesson.price, wallet: 'transaction', return_url: bancontact_complete_lesson_payments_url(lesson)
      }).and_return(TestValidInteraction.run(res: Struct.new(:redirect_url).new('example.com')))
      post :create, lesson_id: lesson.id, mode: 'bancontact', format: :js
    end

    it 'calls Mango::PayinBancontact' do
      expect(Mango::PayinCreditCard).to receive(:run).with({
        user: user, amount: lesson.price, wallet: 'transaction', card_id: '123', return_url: credit_card_complete_lesson_payments_url(lesson)
      }).and_return(TestValidInteraction.run(res: Struct.new(:secure_mode_redirect_url).new('example.com')))
      post :create, lesson_id: lesson.id, card_id: '123', mode: 'cd', format: :js
    end

  end

end
