require 'rails_helper'

RSpec.describe LessonRequestsController, type: :controller do

  describe 'Payment' do
    let(:user){ create(:student, mango_id: '123') }
    let(:lesson){ Lesson.new(attributes_for(:lesson, student: user)).tap{|l| l.save_draft(user)} }

    before(:each){ sign_in user }

    it 'calls PayLessonByTransfert' do
      allow_any_instance_of(PayLesson).to receive(:lesson).and_return(lesson)
      expect(PayLessonByTransfert).to receive(:run).with({user: user, lesson: lesson, wallet: 'transaction'}).and_return(TestValidInteraction.run)
      post :payment, user_id: lesson.teacher_id, mode: 'transfert', format: :js
    end

    it 'calls Mango::PayinBancontact' do
      allow_any_instance_of(PayLesson).to receive(:lesson).and_return(lesson)
      expect(Mango::PayinBancontact).to receive(:run).with({
        user: user, amount: lesson.price, wallet: 'transaction', return_url: bancontact_process_user_lesson_requests_url(lesson.teacher)
      }).and_return(TestValidInteraction.run(res: Struct.new(:redirect_url).new('example.com')))
      post :payment, user_id: lesson.teacher_id, mode: 'bancontact', format: :js
    end

    it 'calls Mango::PayinBancontact' do
      allow_any_instance_of(PayLesson).to receive(:lesson).and_return(lesson)
      expect(Mango::PayinCreditCard).to receive(:run).with({
        user: user, amount: lesson.price, wallet: 'transaction', card_id: '123', return_url: credit_card_process_user_lesson_requests_url(lesson.teacher)
      }).and_return(TestValidInteraction.run(res: Struct.new(:secure_mode_redirect_url).new('example.com')))
      post :payment, user_id: lesson.teacher_id, card_id: '123', mode: 'cd', format: :js
    end

  end

end
