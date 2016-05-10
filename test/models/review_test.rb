require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  test "Review.count" do
    assert_equal 1, Review.count
  end

  test "creation all param" do
    assert_difference 'Review.count' do
      Review.create(:sender => User.first, :subject => User.second, :note => 5)
    end
  end
  test "creation same user" do
    assert_no_difference 'Review.count' do
      Review.create(:sender => User.first, :subject => User.first, :note => 5)
    end
  end
end
