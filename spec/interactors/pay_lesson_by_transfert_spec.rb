require 'rails_helper'

RSpec.describe PayLessonByTransfert do

  let(:user){ create(:student) }
  let(:teacher){ create(:teacher) }
  let(:offer){ create(:offer, user: teacher) }
  let(:level){ offer.levels.find_by(level: 5) }

  let(:lesson){ @lesson }

  before :each do
    @user = user
    Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: user)


    @lesson = Lesson.new(attributes_for(:lesson, {
       student: user,
       teacher: teacher,
       topic: offer.topic,
       topic_group: offer.topic.topic_group,
       time_start: 5.hours.since,
       time_end: 7.hours.since,
       level: level,
       price: 10 * 2
     }))
    @lesson.save_draft(user)
  end

  it 'save draft lesson and create payment', vcr: true do
    payin = Mango::PayinTestCard.run(user: user, amount: 49)
    expect(payin).to be_valid
    user.reload
    paying = PayLessonByTransfert.run( user: user, lesson: lesson )
    expect(paying).to be_valid
    expect(lesson.id).to be
    expect(lesson.payments).to be_any

    payment = lesson.payments.first
    expect(payment.price).to eq(20)
    expect(payment.payment_method).to eq('wallet')

  end

end