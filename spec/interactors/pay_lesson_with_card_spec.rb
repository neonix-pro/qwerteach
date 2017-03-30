require 'rails_helper'

RSpec.describe PayLessonWithCard do

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
      "Status": "SUCCEEDED",
      "PaymentType": "CARD",
      "CardId": "123456"
    }
  end

  let(:user){ create(:student) }
  let(:teacher){ create(:teacher) }
  let(:offer){ create(:offer, user: teacher) }
  let(:level){ offer.levels.find_by(level: 5) }
  let(:lesson){ @lesson }
  let(:transaction_id){ 8494514 }

  before :each do
    @lesson = FactoryGirl.build(:lesson, {
      student: user,
      teacher: teacher,
      topic: offer.topic,
      topic_group: offer.topic.topic_group,
      time_start: 5.hours.since,
      time_end: 7.hours.since,
      level: level,
      price: 10 * 2
    })
    @lesson.save_draft(@user)
    expect(MangoPay::PayIn).to receive(:fetch).with(transaction_id).and_return(transaction)
    expect_any_instance_of(Student).to receive(:mangopay).and_return( Struct.new(:cards).new([]) )
    #Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
  end

  it 'save draft lesson and create prepayment' do



    paying = PayLessonWithCard.run( user: user, lesson: lesson, transaction_id: transaction_id )
    expect(paying).to be_valid
    expect(lesson.id).to be
    expect(lesson.payments).to be_any

    payment = lesson.payments.first
    expect(payment.price).to eq(20)
    expect(payment.payment_method).to eq('creditcard')
    expect(payment.payment_type).to eq('prepayment')
    expect(payment.status).to eq('locked')

  end

  it 'save draft lesson and create postpayment' do
    lesson.update(time_start: 7.hours.ago, time_end: 5.hours.ago)
    paying = PayLessonWithCard.run( user: user, lesson: lesson, transaction_id: transaction_id )
    expect(paying).to be_valid
    expect(lesson.id).to be
    expect(lesson.payments).to be_any

    payment = lesson.payments.first
    expect(payment.price).to eq(20)
    expect(payment.payment_method).to eq('creditcard')
    expect(payment.payment_type).to eq('postpayment')
    expect(payment.status).to eq('paid')

  end

end