require 'rails_helper'

RSpec.describe Mango::SendMakeBankWire do

  before :each do
    @user = FactoryGirl.create(:user, email: FFaker::Internet.email)
    Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
  end

  it 'makes payin bancontact', :vcr do
    payin = Mango::SendMakeBankWire.run(user: @user, amount: 100)
    expect(payin).to be_valid
    expect(payin.result.status).to eq('CREATED')
  end

end