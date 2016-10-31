require 'rails_helper'

RSpec.describe Mango::PayFromWallet do

  before :each do
    @user = FactoryGirl.create(:user, email: FFaker::Internet.email)
    Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
  end

  it 'transfer money from normal wallet to transaction wallet', vcr: true do
    payin = Mango::PayinTestCard.run(user: @user, amount: 80)
    expect(payin).to be_valid
    @user.reload
    transfert = Mango::PayFromWallet.run(user: @user, amount: 50)
    expect(transfert).to be_valid
    @user.reload
    expect(@user.normal_wallet.balance.amount).to eq(3000)
    expect(@user.transaction_wallet.balance.amount).to eq(5000)
  end

  it 'transfer money from bonus wallet to transaction wallet', vcr: true do
    payin = Mango::PayinTestCard.run(user: @user, amount: 80, wallet: 'bonus')
    expect(payin).to be_valid
    @user.reload
    transfert = Mango::PayFromWallet.run(user: @user, amount: 50)
    expect(transfert).to be_valid
    @user.reload
    expect(@user.normal_wallet.balance.amount).to eq(0)
    expect(@user.bonus_wallet.balance.amount).to eq(3000)
    expect(@user.transaction_wallet.balance.amount).to eq(5000)
  end

  it 'transfer money from bonus and normal wallets to transaction wallet', vcr: true do
    payin = Mango::PayinTestCard.run(user: @user, amount: 30)
    expect(payin).to be_valid
    payin = Mango::PayinTestCard.run(user: @user, amount: 30, wallet: 'bonus')
    expect(payin).to be_valid
    @user.reload
    transfert = Mango::PayFromWallet.run(user: @user, amount: 50)
    expect(transfert).to be_valid
    @user.reload
    expect(@user.normal_wallet.balance.amount).to eq(1000)
    expect(@user.bonus_wallet.balance.amount).to eq(0)
    expect(@user.transaction_wallet.balance.amount).to eq(5000)
  end

end