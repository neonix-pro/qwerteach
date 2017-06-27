require 'rails_helper'

feature "payment" do

  scenario "user with account loads wallet" do
    create_user_with_mango
    login_user(@user.email, @user.password)
    expect(page).to have_content('Déconnexion')
    visit('/user/mangopay/load-wallet')
    expect(page).to have_content('Charger mon portefeuille')
    expect(page).to have_field('amount')
    expect(page).to have_field('payment-method')
    expect(page).to have_field('card')
  end

  xscenario "user without account loads wallet" do # did not refactor
    create_user
    login_user(@user.email, @user.password)
    expect(page).to have_content('Déconnexion')
    visit('/user/mangopay/load-wallet')
    expect(page).to have_content('vous devez configurer votre portefeuille virtuel') #redirected to form to create his mangopay account
  end

  def login_user(email, password)
    visit new_user_session_path
    within('.sign_in_page//form') do
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      find('input[type=submit]').click
    end
  end
  def create_user_with_mango
    create_user
    Mango::SaveAccount.run FactoryGirl.attributes_for(:mango_user).merge(user: @user)
  end

  def create_user
    @user = FactoryGirl.create(:user, email: FFaker::Internet.email)
  end
end