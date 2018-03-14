class AddLessonPackIdFieldToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :lesson_pack_id, :integer, index: true
  end
end
