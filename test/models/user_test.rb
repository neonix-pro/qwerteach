require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "users_count" do
    assert_equal 4, User.count
  end

  test "user_type" do
    assert_equal User.first.type, "User"
  end

  test "user_type2" do
    assert User.first.is_a?(User)
  end

  test "user_is_admin" do
    assert_not User.first.admin?
  end
  test "user_is_admin2" do
    User.first.become_admin
    assert User.first.admin?
  end
  test "type_change" do
    User.first.upgrade
    assert User.first.is_a?(Student)
  end
  test "type_change2" do
    config.logger = Logger.new(STDOUT)
    User.first.upgrade
    User.first.upgrade
    assert User.first.is_a?(Teacher)
  end
  test "type_max" do
    User.first.upgrade
    User.first.upgrade
    User.first.upgrade
    assert User.first.is_a?(Teacher)
  end
  test "create account already existing" do
    assert_no_difference 'User.count' do
      User.create(:email => "c@c.c", :firstname => "Bonobo", :lastname => "Chauve", :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "2016-04-25 08:38:01.794478", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
                  :avatar_file_name => "hello3.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :type => 'Teacher')
    end
  end
  test "create account all ok" do
    assert_difference 'User.count' do
      User.create(:email => "e@e.e", :firstname => "Bonobo", :lastname => "Chauve", :password => "kaltrina", :encrypted_password => "$2a$10$kdhcUGrsb7gBk.RHrs2xK.OHMx5gdx7kmLHFozZgRdtigrlbt91Zu", :confirmation_token => "2016-04-25 08:38:01.794478", :confirmation_sent_at => "2016-04-25 08:38:01.794477", :confirmed_at => "2016-04-25 08:38:01.794477",
                  :avatar_file_name => "hello3.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 64813, :avatar_updated_at => "2016-04-25 09:42:55", :type => 'Teacher')
    end
  end
end