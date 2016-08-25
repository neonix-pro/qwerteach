require 'rails_helper'

RSpec.describe Mango::SaveAccount do

  before :each do
    @user = FactoryGirl.create(:user, email: FFaker::Internet.email)
  end

  it 'creates account and wallets in MangoPay', :vcr do
    res = Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
    expect(res).to be_valid
    expect(res.result).to a_kind_of(Fixnum)
    @user.reload
    expect(@user.wallets.size).to eq(3)
    expect(@user.normal_wallet).to be
    expect(@user.bonus_wallet).to be
    expect(@user.transaction_wallet).to be
  end

  it 'updates account in MangoPay', :vcr do
    res = Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
    expect(res).to be_valid
    mango_id = @user.reload.mango_id
    res = Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user, city: 'Barnaul').merge(user: @user)
    expect(res).to be_valid
    @user.reload
    expect(@user.address.city).to eq('Barnaul')
    expect(@user.mango_id).to eq(mango_id)
  end

end