require 'rails_helper'

RSpec.describe Mango::CreateBankAccount do

  before :each do
    @user = FactoryGirl.create(:rand_user)
    Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
  end

  it 'creates IBAN bank account', :vcr do
    res = Mango::CreateBankAccount.run user: @user, type: 'iban', iban: 'FR3020041010124530725S03383', bic: 'CRLYFRPP'
    expect(res).to be_valid
  end

  it 'creates US bank account', :vcr do
    res = Mango::CreateBankAccount.run user: @user, type: 'us', account_number: '11696419', aba: '071000288'
    expect(res).to be_valid
  end

  it 'creates CA bank account', :vcr do
    res = Mango::CreateBankAccount.run user: @user, type: 'ca', branch_code: '00152',
      institution_number: '614', account_number: '11696419', bank_name: 'SberBank'
    expect(res).to be_valid
  end

  # It does not work on https://docs.mangopay.com/endpoints/v2.01/bank-accounts#e13_create-a-gb-bankaccount
  # Error: One or several required parameters are missing or incorrect
  xit 'creates GB bank account', :vcr do
    res = Mango::CreateBankAccount.run user: @user, type: 'gb', sort_code: '001520', account_number: '11696419'
    #expect(res).to be_valid
  end

  it 'creates OTHER bank account', :vcr do
    res = Mango::CreateBankAccount.run user: @user, type: 'other', country: 'FR', bic: 'CRLYFRPP', account_number: '11696419'
    expect(res).to be_valid
  end

end