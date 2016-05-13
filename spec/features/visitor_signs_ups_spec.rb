require 'rails_helper'

feature "VisitorSignsUps" do
  scenario "GET /new_user_registration" do
    visit new_user_registration_path
    expect(page).to have_content("S'inscrire")
  end
end
