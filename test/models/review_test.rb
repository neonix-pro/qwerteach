require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
   test "Review.count" do
     assert_equal 0, Review.count
   end
   
   test "creation sans all param" do
     assert_difference 'Review.count' do
     Review.create(:sender => User.first, :subject => User.second,:note => 5)
    end
   end
end
