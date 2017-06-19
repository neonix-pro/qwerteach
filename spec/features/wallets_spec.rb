require 'rails_helper'
require 'pp'

feature "Wallets" do
  scenario "GET /wallets not logged in" do
    visit index_wallet_path
    expect(page).to have_content("Vous devez vous connecter ou vous inscrire pour continuer. ")
  end
  scenario "test test test" do
    visit new_user_session_path
    expect(page).to have_content('Se connecter')
  end
  xscenario "GET /wallets logged in", vcr: true do
     user = FactoryGirl.create(:student, email: FFaker::Internet.email)
     login_user(user.email, user.password)
     visit index_wallet_path
     expect(page).to have_content("Configurer mon portefeuille virtuel")
     within(".main-content") do
       fill_in 'account[first_name]', with: user.firstname
       fill_in 'account[last_name]', with: user.lastname
       fill_in 'account[address_line1]', with: 'ZEGIJOERZJGOERZ'
       fill_in 'account[address_line2]', with: '22EF'
       fill_in 'account[postal_code]', with: '87172'
       fill_in 'account[city]', with: 'FOKGPOER'
       fill_in 'account[region]', with: 'EIJGERIGJE'
       select "France", :from => "account[country]"
       select "France", :from => "account[country_of_residence]"
       select "France", :from => "account[nationality]"
       find('button[type=submit]').click
     end

     expect(page).to have_content("0.0 EUR 0.0 EUR de crédit bonus")
     visit load_wallet_path
     expect(page).to have_content("Charger mon portefeuille")
     
     # within(".main-content") do
     #   fill_in 'amount', with: 25
     #   select 'CB_VISA_MASTERCARD', :from => "card_type"
     #   find('#edit_user button[type=submit]').click
     # end
     # expect(page).to have_content("Numero")
     # within(".main-content") do
     #
     #   fill_in 'cardNumber', with: '3569990000000132'
     #   #fill_in 'cardExpirationDate', with: '1020'
     #   #fill_in 'year', with: 19
     #   select 'juillet', from: 'date_month'
     #   select 2020, from: 'year'
     #   fill_in 'cardCvx', with: '123'
     #
     #   #find('input[type=submit]').click
     #   #expect(page.status_code).to eq(302)
     #   #expect(page.response_headers['Location']).to include('ACSWithValidation')
     # end

     # all happens at once now
   end
 
   def login_user(email, password)
     visit new_user_session_path
     within(".main-content") do
       fill_in 'user_email', with: email
       fill_in 'user_password', with: password
       find('input[type=submit]').click
     end
   end
 end