require 'rails_helper'

RSpec.describe Mango::TransferBetweenWallets do

  before :each do
    @user = FactoryBot.create(:user, email: FFaker::Internet.email)
    Mango::SaveAccount.run FactoryBot.attributes_for(:mango_user).merge(user: @user)
  end

  it 'makes payin from test card', :vcr do
    payin = Mango::PayinTestCard.run(user: @user, amount: 45)
    expect(payin).to be_valid
    transfer = Mango::TransferBetweenWallets.run({
      user: @user, amount: 30,
      debited_wallet_id: @user.normal_wallet.id,
      credited_wallet_id: @user.transaction_wallet.id
    })
    expect(transfer).to be_valid
    @user.reload
    expect(@user.normal_wallet.balance.amount ).to eq(1500)
    expect(@user.transaction_wallet.balance.amount ).to eq(3000)
  end

end