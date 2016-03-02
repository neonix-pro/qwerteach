require 'test_helper'

class UserResetpasswordTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "valid reset pwd" do
    get new_user_password_path
    post user_password_path, 'user[email]' => 'y@y.y'
    assert_redirected_to new_user_session_path
  end
  test "invalid reset pwd : wrong email" do
    get new_user_password_path
    post user_password_path, 'user[email]' => 'k@y.y'
    assert_template 'devise/passwords/new'
  end
  test "invalid reset pwd : empty email" do
    get new_user_password_path
    post user_password_path, 'user[email]' => ''
    assert_template 'devise/passwords/new'
  end
end
