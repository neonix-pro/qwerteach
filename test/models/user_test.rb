require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "users_count" do
    assert_equal 2, User.count
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
    config.logger.debug User.first.type
    assert User.first.is_a?(Teacher)
  end
  test "type_max" do
    User.first.upgrade
    User.first.upgrade
    User.first.upgrade
    assert User.first.is_a?(Teacher)
  end
  test "is_prof_accepted" do
    assert_not User.first.is_prof
  end
  test "is_prof_accepted2" do
    User.first.upgrade
    assert_not User.first.is_prof
  end
  test "is_prof_accepted3" do
    User.first.upgrade
    User.first.upgrade
    assert_not User.first.is_prof
  end
  test "is_prof_accepted4" do
    User.first.upgrade
    User.first.upgrade
    User.first.accept_postulance
    assert User.first.is_prof
  end
  test "is_prof_postulant" do
    assert_not User.first.is_prof_postulant
  end
  test "is_prof_postulant2" do
    User.first.upgrade
    assert_not User.first.is_prof_postulant
  end
  test "is_prof_postulant3" do
    User.first.upgrade
    User.first.upgrade
    assert User.first.is_prof_postulant
  end
end
