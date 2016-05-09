require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "the truth" do
    assert_equal 1, Comment.count
  end
  test "no text" do
    comment = Comment.first.update(:comment_text => nil)
    assert_not comment
  end
  test "no sender" do
    comment = Comment.first.update(:sender => nil)
    assert_not comment
  end
  test "no subject" do
    comment = Comment.first.update(:subject => nil)
    assert_not comment
  end
  test "all ok" do
    assert_difference "Comment.count" do
      Comment.create(:comment_text => "trop beau", :subject => User.first, :sender => User.second)
    end
  end
end
