require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get new_user_registration_path
    assert_no_difference 'User.count' do
      post user_registration_path, user: {
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"}
    end
    assert_template 'devise/registrations/new'
  end
  test "valid signup information" do
    get new_user_registration_path
    assert_difference 'User.count' do
      post user_registration_path, user: {
          email: "user@valid.com",
          password: "kaltrina",
          password_confirmation: "kaltrina"}
    end
    assert_template 'devise/mailer/confirmation_instructions'
  end
  test "invalid signup information : pwd too short" do
    get new_user_registration_path
    assert_no_difference 'User.count' do
      post user_registration_path, user: {
          email: "user@invalid.com",
          password: "foo",
          password_confirmation: "foo"}
    end
    assert_template 'devise/registrations/new'
  end
  test "invalid signup information :email invalid" do
    get new_user_registration_path
    assert_no_difference 'User.count' do
      post user_registration_path, user: {
          email: "user@invalid",
          password: "foofoofoo",
          password_confirmation: "foofoofoo"}
    end
    assert_template 'devise/registrations/new'
  end
end
