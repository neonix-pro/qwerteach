require 'test_helper'

class AdvertPriceTest < ActiveSupport::TestCase
   test "AdvertPrice.count" do
     assert_equal 11, OfferPrice.count
   end
   
   test "creationSansParam" do
     a = OfferPrice.new
     assert_not a.save
   end
  
  test "AdvertPriceNegatif" do
    assert 'AdvertPrice.count' do
  OfferPrice.create(:offer => one, :level_id => 5, :price => -5.0)
    end
  end
  
  
end
