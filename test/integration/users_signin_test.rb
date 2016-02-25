require 'test_helper'


class UsersSigninTest < ActionDispatch::IntegrationTest
   test "valid signin information" do
     get new_user_session_path
     post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'


   end
end
