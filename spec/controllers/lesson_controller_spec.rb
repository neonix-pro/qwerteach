require 'rails_helper'

RSpec.describe LessonsController, type: :controller do

  describe 'Accept' do
    let(:user){ create(:student) }
    let(:lesson){ create(:lesson, student: user) }

    before(:each){ sign_in user }

    it 'redirects to payment form unless lesson paid and can not be paid afterwards' do
      get :accept, lesson_id: lesson.id
      expect(response).to redirect_to new_lesson_payment_path(lesson)
    end

    it 'calls accept interaction' do
      lesson.update(pay_afterwards: true)
      expect(AcceptLesson).to receive(:run).with(user: user, lesson: lesson).and_return(TestValidInteraction.run(res: {}))
      get :accept, lesson_id: lesson.id
    end

  end

end