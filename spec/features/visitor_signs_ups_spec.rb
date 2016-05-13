require 'rails_helper'

feature "UserSignsUps" do
  scenario "GET /new_user_registration" do
    visit new_user_registration_path
    expect(page).to have_content("S'inscrire")
  end
  scenario 'with invalid email' do
    sign_up_with 'invalid_email', 'password', 'password'
    expect(page).to have_content("Email n'est pas valide")
  end
  scenario 'with invalid password' do
    sign_up_with 'p@p.p', 'passwo', 'passwo'
    expect(page).to have_content("Password est trop court")
  end
  scenario 'with not same passwords' do
    sign_up_with 'p@p.p', 'password', 'passwo'
    expect(page).to have_content("Password confirmation ne concorde pas avec Password")
  end
  scenario 'with not same passwords' do
    sign_up_with 'p@p.p', 'password', 'password'
    expect(page).to have_content("Un message contenant un lien de confirmation a été envoyé à votre adresse email")
  end
  def sign_up_with(email, password, password_confirmation)
    visit new_user_registration_path
    within("#body") do
      fill_in 'user_email', with: email
      fill_in 'user[password]', with: password
      fill_in 'user[password_confirmation]', with: password_confirmation
      click_button 'Sign up'
    end
  end
end
feature "UserUnlockInstructions" do
  scenario "right unlock information" do
    User.first.lock_access!
    ask_unlock_information(User.first.email)
    expect(page).to have_content("Vous allez recevoir les instructions nécessaires au déverrouillage de votre compte dans quelques instants")
  end
  scenario "unlocked account" do
    ask_unlock_information(User.first.email)
    expect(page).to have_content("Email n'était pas verrouillé(e)")
  end
  scenario "wrong email" do
    ask_unlock_information('aha@aha.kkkk')
    expect(page).to have_content("Email n'a pas été trouvé(e)")
  end
  scenario "wrong email" do
    ask_unlock_information('')
    expect(page).to have_content("Email doit être rempli(e)")
  end
  def ask_unlock_information(email)
    visit new_user_unlock_path
    within("#body") do
      fill_in 'user_email', with: email
      find('input[type=submit]').click
    end
  end
end
feature "UserResetPassword" do
  scenario "right reset information" do
    ask_reset_password(User.first.email)
    expect(page).to have_content("Vous allez recevoir les instructions de réinitialisation du mot de passe dans quelques instants")
  end
  scenario "wrong email" do
    ask_reset_password('aha@aha.kkkk')
    expect(page).to have_content("Email n'a pas été trouvé(e)")
  end
  scenario "wrong email" do
    ask_reset_password('')
    expect(page).to have_content("Email doit être rempli(e)")
  end
  def ask_reset_password(email)
    visit new_user_password_path
    within("#body") do
      fill_in 'user_email', with: email
      find('input[type=submit]').click
    end
  end
end
feature "UserResendInstructions" do
  scenario "right resend instructions" do
    user = User.first
    user.update_attributes(:confirmed_at=>nil)
    user.save!
    ask_resend_insctructions(user.email)
    expect(page).to have_content("Vous allez recevoir les instructions nécessaires à la confirmation de votre compte dans quelques minutes")
  end
  scenario "wrong email" do
    ask_resend_insctructions('aha@aha.kkkk')
    expect(page).to have_content("Email n'a pas été trouvé(e)")
  end
  scenario "wrong email" do
    ask_resend_insctructions('')
    expect(page).to have_content("Email doit être rempli(e)")
  end
  scenario "already confirmed" do
    ask_resend_insctructions(User.first.email)
    expect(page).to have_content("Email a déjà été validé(e), veuillez essayer de vous connecter")
  end
  def ask_resend_insctructions(email)
    visit new_user_confirmation_path
    within("#body") do
      fill_in 'user_email', with: email
      find('input[type=submit]').click
    end
  end
end