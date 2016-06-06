require 'rails_helper'

# NOT WORKING, WE NEED TO ALLOW EXTERNAL REQUESTS

feature "Wallets" do
  scenario "GET /wallets not logged in" do
    visit index_wallet_path
    expect(page).to have_content("Vous devez vous connecter ou vous inscrire pour continuer. ")
  end
  scenario "test test test" do
    visit new_user_session_path
    expect(page).to have_content('Log in')
  end
  scenario "GET /wallets logged in" do
    login_user('z@z', 'password')
    visit index_wallet_path
    expect(page).to have_content('Log in')
   
  end

  def login_user(email, password)
    visit new_user_session_path
    within("#body") do
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      find('input[type=submit]').click
    end
  end
end
