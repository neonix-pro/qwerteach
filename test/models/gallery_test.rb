require 'test_helper'

class GalleryTest < ActiveSupport::TestCase
   test "the truth" do
     assert_equal 2, Gallery.count
   end

  test "one gallery" do
    g = Gallery.create(:user_id => 1)
    assert_not_nil g
  end

  test "one_by_user" do
    Gallery.create(:user_id => 1)
    Gallery.create(:user_id => 1)
    assert_raise Exception
  end
  test "no gallery found" do
    assert_raises ActiveRecord::RecordNotFound do
      Gallery.find(10)
    end
  end
  test "no gallery found 2" do
    assert_raises ActiveRecord::RecordNotFound do
      Gallery.find(:user_id => 45)
    end
  end
  test "no user_id" do
    gallery = Gallery.first.update(:user => nil)
    assert_not gallery
  end
end
