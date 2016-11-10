require 'rails_helper'

RSpec.describe PayLessonByBancontact do

  let :transaction do
    {
      "Id": "8494514",
      "CreationDate": 12926321,
      "CreditedFunds": {
        "Currency": "EUR",
        "Amount": 2000
      },
      "Fees": {
        "Currency": "EUR",
        "Amount": 12
      },
      "Nature": "REGULAR",
      "Status": "SUCCEEDED"
    }
  end

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
    #Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
  end

  it 'save draft lesson and create payment' do
    expect(MangoPay::PayIn).to receive(:fetch){ transaction }
    paying = PayLessonByBancontact.run( user: @user, lesson: @lesson, transaction_id: 8494514 )
    expect(paying).to be_valid
    expect(@lesson.id).to be
    expect(@lesson.payments).to be_any

    payment = @lesson.payments.first
    expect(payment.price).to eq(20)
    expect(payment.payment_method).to eq('bcmc')
  end

end