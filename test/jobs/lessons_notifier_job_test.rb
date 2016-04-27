require 'test_helper'

class LessonsNotifierJobTest < ActiveJob::TestCase

  test "fonctionne" do
    assert_equal 3, Lesson.count
    assert_difference 'User.second.mailbox.notifications.count' do
      LessonsNotifierJob.perform_now()
    end
  end

end
