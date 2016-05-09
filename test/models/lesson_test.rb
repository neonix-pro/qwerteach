require 'test_helper'

class LessonTest < ActiveSupport::TestCase
  test "the truth" do
    assert_equal 3, Lesson.count
  end
  test "no student_id" do
    lesson = Lesson.first.update(:student_id => nil)
    assert_not lesson
  end
  test "no teacher_id" do
    lesson = Lesson.first.update(:teacher_id => nil)
    assert_not lesson
  end
  test "no time_start" do
    lesson = Lesson.first.update(:time_start => nil)
    assert_not lesson
  end
  test "no time_end" do
    lesson = Lesson.first.update(:time_end => nil)
    assert_not lesson
  end
  test "no topic_group_id" do
    lesson = Lesson.first.update(:topic_group_id => nil)
    assert_not lesson
  end
  test "no level_id" do
    lesson = Lesson.first.update(:level_id => nil)
    assert_not lesson
  end
  test "no price" do
    lesson = Lesson.first.update(:price => nil)
    assert_not lesson
  end
  test "no status" do
    lesson = Lesson.first.update(:status => nil)
    assert_not lesson
  end
  test "wrong price" do
    lesson = Lesson.first.update(:price => -5)
    assert_not lesson
  end
  test "wrong time_end" do
    lesson = Lesson.first.update(:time_end => DateTime.now - 2.hours)
    assert_not lesson
  end
  test "wrong time_start" do
    lesson = Lesson.first.update(:time_start => DateTime.now - 2.hours)
    assert_not lesson
  end
  test "time_end & time_start ok" do
    lesson = Lesson.first.update(:time_end => DateTime.now + 2.months, :time_start => DateTime.now + 1.months)
    assert lesson
  end
  test "all ok" do
    assert_difference "Lesson.count" do
      Lesson.create(:student_id => 1, :teacher_id => 3, :topic_group_id => 3, :level_id => 15, :topic_id => 9, :price => 15.0, :time_end => DateTime.now + 2.months, :time_start => DateTime.now + 1.months)
    end
  end
end
