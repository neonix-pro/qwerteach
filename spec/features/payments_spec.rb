require 'rails_helper'


feature "payment" do
    scenario "" do
        login_user('a@a.a', 'kaltrina')
        expect(page).to have_content('Bonjour MacaqueSelfieur')
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