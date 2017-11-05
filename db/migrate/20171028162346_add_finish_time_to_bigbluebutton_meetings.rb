class AddFinishTimeToBigbluebuttonMeetings < ActiveRecord::Migration
  def change
    add_column :bigbluebutton_meetings, :finish_time, :integer, :limit => 8, :null => true
  end
end
