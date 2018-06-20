require 'rails_helper'

RSpec.describe Mango::PayFromWallet do

  before :each do
    @user = FactoryBot.create(:user, email: FFaker::Internet.email)
    Mango::SaveAccount.run FactoryBot.attributes_for(:mango_user).merge(user: @user)
  end

  it 'transfer money from normal wallet to transaction wallet', vcr: true do
    payin = Mango::PayinTestCard.run(user: @user, amount: 45)
    expect(payin).to be_valid
    sleep 10
    @user.reload
    expect(@user.normal_wallet.balance.amount).to eq(4500)
    transfert = Mango::PayFromWallet.run(user: @user, amount: 20)
    expect(transfert).to be_valid
    @user.reload
    expect(@user.normal_wallet.balance.amount).to eq(2500)
    expect(@user.transaction_wallet.balance.amount).to eq(2000)
  end

  it 'transfer money from bonus wallet to transaction wallet', vcr: true do
    payin = Mango::PayinTestCard.run(user: @user, amount: 45, wallet: 'bonus')
    expect(payin).to be_valid
    @user.reload
    transfert = Mango::PayFromWallet.run(user: @user, amount: 20)
    expect(transfert).to be_valid
    @user.reload
    expect(@user.normal_wallet.balance.amount).to eq(0)
    expect(@user.bonus_wallet.balance.amount).to eq(2500)
    expect(@user.transaction_wallet.balance.amount).to eq(2000)
  end

  it 'transfer money from bonus and normal wallets to transaction wallet', vcr: true do
    payin = Mango::PayinTestCard.run(user: @user, amount: 20)
    expect(payin).to be_valid
    payin = Mango::PayinTestCard.run(user: @user, amount: 20, wallet: 'bonus')
    expect(payin).to be_valid
    @user.reload
    transfert = Mango::PayFromWallet.run(user: @user, amount: 35)
    expect(transfert).to be_valid
    @user.reload
    expect(@user.normal_wallet.balance.amount).to eq(500)
    expect(@user.bonus_wallet.balance.amount).to eq(0)
    expect(@user.transaction_wallet.balance.amount).to eq(3500)
  end

  let(:wallet){ Struct.new(:id) }

  it 'use normal wallet' do
    expect(@user).to receive(:normal_wallet).and_return(wallet.new('123'))
    expect(Mango::PayinTestCard.new(user: @user, amount: 20).send(:beneficiary_wallet_id)).to eq('123')
  end

  it 'use bonus wallet' do
    expect(@user).to receive(:bonus_wallet).and_return(wallet.new('321'))
    expect(Mango::PayinTestCard.new(user: @user, amount: 20, wallet: 'bonus').send(:beneficiary_wallet_id)).to eq('321')
  end

  it 'use transaction wallet' do
    expect(@user).to receive(:transaction_wallet).and_return(wallet.new('222'))
    expect(Mango::PayinTestCard.new(user: @user, amount: 20, wallet: 'transaction').send(:beneficiary_wallet_id)).to eq('222')
  end

  it 'use foreign wallet' do
    expect(Mango::PayinTestCard.new(user: @user, amount: 20, wallet: '1234').send(:beneficiary_wallet_id)).to eq('1234')
  end

end