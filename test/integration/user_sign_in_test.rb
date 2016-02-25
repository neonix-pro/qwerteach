require 'test_helper'

class UserSignInTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "invalid signin information" do
    get user
    assert_no_difference 'User.count' do
      post user_registration_path, user: {
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"}
    end
    assert_template 'devise/registrations/new'
  end

end
