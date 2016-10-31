require 'rails_helper'

RSpec.describe CalculateLessonPrice do

  before :each do
    @teacher = FactoryGirl.create(:teacher, email: FFaker::Internet.email)
    @advert = FactoryGirl.create(:advert, user: @teacher)
  end

  it 'calculate lesson price for level 5' do
    calculation = CalculateLessonPrice.run({
      teacher_id: @teacher.id,
      hours: 2,
      minutes: 30,
      topic_id: @advert.topic_id,
      level_id: @advert.advert_prices.map(&:level).find{|l| l.level == 5 }.id
    })
    expect(calculation).to be_valid
    expect(calculation.result).to eq( 10 * 2.5 )
  end

  it 'calculate lesson price for level 10' do
    calculation = CalculateLessonPrice.run({
      teacher_id: @teacher.id,
      hours: 3,
      minutes: 0,
      topic_id: @advert.topic_id,
      level_id: @advert.advert_prices.map(&:level).find{|l| l.level == 10 }.id
    })
    expect(calculation).to be_valid
    expect(calculation.result).to eq( 20 * 3 )
  end

  it 'calculate lesson price for level 15' do
    calculation = CalculateLessonPrice.run({
      teacher_id: @teacher.id,
      hours: 1,
      minutes: 45,
      topic_id: @advert.topic_id,
      level_id: @advert.advert_prices.map(&:level).find{|l| l.level == 15 }.id
    })
    expect(calculation).to be_valid
    expect(calculation.result).to eq( 30 * (1 + 45.0/60) )
  end


end