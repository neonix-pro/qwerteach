require 'test_helper'

class PostulationTest < ActiveSupport::TestCase
  test "the truth" do
    assert_equal 1, Postulation.count
  end
  test "only one postulation by user" do
    Postulation.create(:user_id => User.third.id)
    assert_raise Exception
  end
  test "all ok" do
    assert_difference "Postulation.count" do
       Postulation.create(:user_id => User.fourth.id, :interview_ok => true, :avatar_ok => true)
    end
  end
end
