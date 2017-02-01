class CreateTableMeetingsUsers < ActiveRecord::Migration
  def change
    create_table :bigbluebutton_meetings_users do |t|
      t.integer :bbb_meeting_id
      t.integer :user_id
    end
  end
end
