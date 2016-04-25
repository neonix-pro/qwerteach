class AddLessonToBbbRoom < ActiveRecord::Migration
  def change
    add_reference :bigbluebutton_rooms, :lesson
  end
end
