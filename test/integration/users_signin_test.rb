require 'test_helper'


class UsersSigninTest < ActionDispatch::IntegrationTest
   test "valid signin information" do
     get new_user_session_path
     post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
     assert_redirected_to root_path
   end
   test "invalid signin information: wrong pwd" do
     get new_user_session_path
     post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrinaa'
     assert_template 'devise/sessions/new'
   end
   test "invalid signin information : no user with email" do
     get new_user_session_path
     post user_session_path, 'user[email]' => 'k@y.y', 'user[password]' => 'kaltrina'
     assert_template 'devise/sessions/new'
   end
   test "invalid signin information : no information" do
     get new_user_session_path
     post user_session_path, 'user[email]' => '', 'user[password]' => ''
     assert_template 'devise/sessions/new'
   end
   test "invalid signin information : no user" do
     get new_user_session_path
     post user_session_path, 'user[email]' => '', 'user[password]' => 'kaltrina'
     assert_template 'devise/sessions/new'
   end
   test "invalid signin information : no pwd" do
     get new_user_session_path
     post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => ''
     assert_template 'devise/sessions/new'
   end
   test "post sur route definie en get" do
     post new_user_session_path
     assert_template 'devise/sessions/new'
   end
   test "get sur route definie en post" do
     get new_user_session_path
     get user_session_path
     assert_template 'devise/sessions/new'
   end

end
