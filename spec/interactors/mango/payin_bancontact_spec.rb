require 'rails_helper'

RSpec.describe Mango::PayinBancontact do

  before :each do
    @user = FactoryGirl.create(:user, email: FFaker::Internet.email)
    Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
  end

  it 'makes payin bancontact', :vcr do
    payin = Mango::PayinBancontact.run(user: @user, amount: 50, fees: 3, return_url: 'http://test.com')
    expect(payin).to be_valid
    expect(payin.result.status).to eq('CREATED')
  end

  it 'fails negative payin bancontact', :vcr do
    payin = Mango::PayinBancontact.run(user: @user, amount: -50, fees: 3, return_url: 'http://test.com')
    expect(payin).not_to be_valid
    expect(payin.result).to be_nil
    expect(payin.errors.full_messages).to include("CreditedFund can't be negative")
  end

  it 'fails negative fees payin bancontact', :vcr do
    payin = Mango::PayinBancontact.run(user: @user, amount: 50, fees: -3, return_url: 'http://test.com')
    expect(payin).not_to be_valid
    #expect(payin.result).to be_nil
    expect(payin.errors.full_messages).to include("Fees The value cannot be negative")
  end
end