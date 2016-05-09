require 'test_helper'

class TopicGroupTest < ActiveSupport::TestCase
  test "the truth" do
     assert_equal 6, TopicGroup.count
  end
  test "no title" do
    topic_group = TopicGroup.first.update(:title => nil)
    assert_not topic_group
  end
  test "no level_code" do
    topic_group = TopicGroup.first.update(:level_code => nil)
    assert_not topic_group
  end
  test "all ok" do
    assert_difference "TopicGroup.count" do
      TopicGroup.create(:level_code => 20, :title => "Expert")
    end
  end
end
