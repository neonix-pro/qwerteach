require 'test_helper'

class LevelTest < ActiveSupport::TestCase
  test " Level count" do
    assert_equal 30, Level.count
   end
   
   test "CreationSansAllParams" do
     assert_equal 30, Level.count
   Level.create(:level=>7, :be=>"C2 Compétent/Courant", :fr=>"C2 Compétent/Courant", :ch=>"C2 Compétent/Courant")
  end
    
end
