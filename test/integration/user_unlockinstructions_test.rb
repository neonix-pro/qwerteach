require 'test_helper'

class UserUnlockinstructionsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "valid unlock instructions" do
    User.find(1).lock_access!
    get new_user_unlock_path
    post user_unlock_path, 'user[email]' => 'k@k.k'
    assert_redirected_to new_user_session_path
  end
  test "invalid unlock instructions : wrong email" do
    get new_user_unlock_path
    post user_unlock_path, 'user[email]' => 'y@k.k'
    assert_template 'devise/unlocks/new'
  end
  test "invalid unlock instructions : empty email" do
    get new_user_unlock_path
    post user_unlock_path, 'user[email]' => ''
    assert_template 'devise/unlocks/new'
  end
  test "invalid unlock instructions : not locked" do
    get new_user_unlock_path
    post user_unlock_path, 'user[email]' => 'y@y.y'
    assert_template 'devise/unlocks/new'
  end
end
