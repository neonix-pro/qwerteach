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

  let(:wallet){ Struct.new(:id) }

  it 'use normal wallet' do
    expect(@user).to receive(:normal_wallet).and_return(wallet.new('123'))
    expect(Mango::PayinBancontact.new(user: @user, amount: 20).send(:beneficiary_wallet_id)).to eq('123')
  end

  it 'use bonus wallet' do
    expect(@user).to receive(:bonus_wallet).and_return(wallet.new('321'))
    expect(Mango::PayinBancontact.new(user: @user, amount: 20, wallet: 'bonus').send(:beneficiary_wallet_id)).to eq('321')
  end

  it 'use transaction wallet' do
    expect(@user).to receive(:transaction_wallet).and_return(wallet.new('222'))
    expect(Mango::PayinBancontact.new(user: @user, amount: 20, wallet: 'transaction').send(:beneficiary_wallet_id)).to eq('222')
  end

  it 'use foreign wallet' do
    expect(Mango::PayinBancontact.new(user: @user, amount: 20, wallet: '1234').send(:beneficiary_wallet_id)).to eq('1234')
  end
end