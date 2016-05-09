require 'test_helper'

class AdvertPriceTest < ActiveSupport::TestCase
   test "AdvertPrice.count" do
     assert_equal 11, AdvertPrice.count
   end
   
   test "creationSansParam" do
     a = AdvertPrice.new
     assert_not a.save
   end
  
  test "AdvertPriceNegatif" do
    assert 'AdvertPrice.count' do
  AdvertPrice.create(:advert => one, :level_id => 5, :price => -5.0)
    end
  end
  
  
end
