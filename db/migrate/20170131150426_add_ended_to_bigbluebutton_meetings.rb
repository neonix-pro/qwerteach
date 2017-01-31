class AddEndedToBigbluebuttonMeetings < ActiveRecord::Migration
  def change
    add_column :bigbluebutton_meetings, :ended, :boolean
  end
end
