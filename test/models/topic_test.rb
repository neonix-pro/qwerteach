require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test "the truth" do
     assert_equal 27, Topic.count
  end
  test "no title" do
    topic = Topic.first.update(:title => nil)
    assert_not topic
  end
  test "no topic_group_id" do
    topic = Topic.first.update(:topic_group_id => nil)
    assert_not topic
  end
  test "all ok" do
    assert_difference "Topic.count" do
      Topic.create(:topic_group_id => 4, :title => "Albanais")
    end
  end
end
