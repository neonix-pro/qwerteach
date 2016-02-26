require 'test_helper'

class PictureNewTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "get picture" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    @picture=Gallery.where(:user_id=>User.find(2)).last.pictures.last
    get picture_path(@picture)
    assert_equal 200, status
  end
  test "delete picture" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    @gallery = Gallery.where(:user_id=>User.find(2)).last
    @picture=@gallery.pictures.last
    delete picture_path(@picture)
    assert_redirected_to gallery_path(@gallery)
  end
end
