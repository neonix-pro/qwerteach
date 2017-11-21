module FeaturesMacros

  def sign_in(user = nil)
    user ||= create(:user, password: 'password')
    visit new_user_session_path
    within('.sign_in_page//form') do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      find('input[type=submit]').click
    end
  end

  def sign_in_as_admin
    admin = create(:admin, password: 'password')
    sign_in(admin)
    admin
  end

end

RSpec.configure do |config|
  config.include FeaturesMacros, :type => :feature
end