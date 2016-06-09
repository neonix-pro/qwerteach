require 'rails_helper'


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
   user = User.first
     user.mango_id=nil
     user.save
     login_user(user.email, 'kaltrina')
     
     visit index_wallet_path
     expect(page).to have_content("Mes informations bancaires")
     within("#body") do
       fill_in 'FirstName', with: user.firstname
       fill_in 'LastName', with: user.lastname
       fill_in 'Address_AddressLine1', with: 'ZEGIJOERZJGOERZ'
       fill_in 'Address_AddressLine2', with: '22EF'
       fill_in 'Address_PostalCode', with: '87172'
       fill_in 'Address_City', with: 'FOKGPOER'
       fill_in 'Address_Region', with: 'EIJGERIGJE'
       select "France", :from => "Address_Country"
       select "France", :from => "CountryOfResidence"
       select "France", :from => "Nationality"
       find('input[type=submit]').click
     end
     
     expect(page).to have_content("0.0 EUR + 0.0 EUR de crédit bonus")
     visit direct_debit_path
     expect(page).to have_content("Charger mon portefeuille")
     
     within("#body") do
       fill_in 'amount', with: 25
       # select 'CB_VISA_MASTERCARD', :from => "card_type"
       find('input[type=submit]').click
     end
     expect(page).to have_content("Numero")
     within("#body") do
 
       fill_in 'account', with: '3569990000000132'
       fill_in 'month', with: 11
       fill_in 'year', with: 19
       fill_in 'csc', with: '123'
       begin
         find('input[type=submit]').click
       end
       expect(page.status_code).to eq(302)
       expect(page.response_headers['Location']).to include('ACSWithValidation')
     end
 
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