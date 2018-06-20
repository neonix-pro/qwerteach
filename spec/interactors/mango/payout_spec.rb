require 'rails_helper'

RSpec.describe Mango::Payout do

  before :each do
    @user = FactoryBot.create(:rand_user)
    Mango::SaveAccount.run FactoryBot.attributes_for(:mango_user).merge(user: @user)
  end

  it 'makes payout', vcr: true do
    payin = Mango::PayinTestCard.run(user: @user, amount: 45)
    expect(payin).to be_valid
    creating_bank_account = Mango::CreateBankAccount.run user: @user, type: 'iban', iban: 'FR3020041010124530725S03383', bic: 'CRLYFRPP'
    expect(creating_bank_account).to be_valid
    @user.reload
    payout = Mango::Payout.run(user: @user, bank_account_id: @user.bank_accounts.first.id)
    expect(payout).to be_valid
    @user.reload
    expect(@user.normal_wallet.balance.amount).to eq(0)
    expect(@user.transaction_wallet.balance.amount).to eq(0)
  end

end