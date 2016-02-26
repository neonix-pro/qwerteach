require 'test_helper'

class UserResendinstructionsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "valid resend instructions" do
    get new_user_confirmation_path
    post user_confirmation_path, 'user[email]' => 'k@k.k'
    assert_redirected_to new_user_session_path
  end
  test "invalid resend instructions : wrong email" do
    get new_user_confirmation_path
    post user_confirmation_path, 'user[email]' => 'y@k.k'
    assert_template 'devise/confirmations/new'
  end
  test "invalid resend instructions : empty email" do
    get new_user_confirmation_path
    post user_confirmation_path, 'user[email]' => ''
    assert_template 'devise/confirmations/new'
  end
  test "invalid resend instructions : already confirmed" do
    get new_user_confirmation_path
    post user_confirmation_path, 'user[email]' => 'y@y.y'
    assert_template 'devise/confirmations/new'
  end
end
