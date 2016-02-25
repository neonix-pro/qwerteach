require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "truth" do
    assert true
  end
  
  test "invalid signup information" do
    get new_user_registration_path
    assert_no_difference 'User.count' do
      post user_registration_path, user: {
                                     email: "user@invalid",
                                     password:              "foo",
                                     password_confirmation: "bar" }
    end
    assert_template 'devise/registrations/new'
  end
end
