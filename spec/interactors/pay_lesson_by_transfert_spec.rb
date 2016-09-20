require 'rails_helper'

RSpec.describe PayLessonByTransfert do

  before :each do
    @user = FactoryGirl.create(:student, email: FFaker::Internet.email)
    @teacher = FactoryGirl.create(:teacher, email: FFaker::Internet.email)
    @advert = FactoryGirl.create(:advert, user: @teacher)
    @level = @advert.advert_prices.map(&:level).find{|l| l.level == 5 }
    
    @lesson = FactoryGirl.build(:lesson, {
      student: @user,
      teacher: @teacher,
      topic: @advert.topic,
      topic_group: @advert.topic.topic_group,
      time_start: 5.hours.since,
      time_end: 7.hours.since,
      level: @level,
      price: 10 * 2
    })
    @lesson.save_draft(@user)

    Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
  end

  it 'save draft lesson and create payment', vcr: true do
    payin = Mango::PayinTestCard.run(user: @user, amount: 80)
    expect(payin).to be_valid
    @user.reload
    paying = PayLessonByTransfert.run( user: @user, lesson: @lesson )
    expect(paying).to be_valid
    expect(@lesson.id).to be
    expect(@lesson.payments).to be_any

    payment = @lesson.payments.first
    expect(payment.price).to eq(20)
    expect(payment.payment_method).to eq('wallet')

  end

end