class ChangeFreeLessonCase < ActiveRecord::Migration
  def change
    rename_column :lessons, :freeLesson, :free_lesson
  end
end
