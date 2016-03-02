require 'test_helper'

class GalleryEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "get gallery" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    @gallery=Gallery.where(:user_id => User.find(2)).last.id
    get gallery_path(@gallery)
    assert_equal 200, status
  end
  test "get edit gallery" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    @gallery=Gallery.where(:user_id => User.find(2)).last.id
    get edit_gallery_path(@gallery)
    assert_equal 200, status
  end
  test "delete gallery" do
    post user_session_path, 'user[email]' => 'y@y.y', 'user[password]' => 'kaltrina'
    assert_no_difference 'Gallery.count' do
      @gallery = Gallery.where(:user_id => User.find(2)).last
      delete gallery_path(@gallery)
    end
    assert_redirected_to root_path
    assert_equal 302, status
  end
end
