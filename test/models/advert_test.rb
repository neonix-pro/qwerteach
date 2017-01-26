require 'test_helper'

class AdvertTest < ActiveSupport::TestCase
   test "Advert.count" do
     assert_equal 4, Offer.count
   end
   
   test "AdvertSansTopic" do
     a = Offer.new
     assert_not a.save
   end
   
   test "AdvertSameParams" do
     assert 'Advert.count' do
       Offer.create(:user => 3, :topic_id => 5, :topic_group_id => 2)
     end
   end
   

   
end
